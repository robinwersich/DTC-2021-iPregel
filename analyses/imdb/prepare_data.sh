#!/bin/bash

# navigate to root directory
cd "$(dirname "$0")"

if [ -d "data_prepared" ]; then
    echo "Data already present."
else
    # download data
    if [ -d "data_original" ]; then
        echo "Downloaded data found."
    else
        ( # execute in subshell to catch errors and clean up afterwards
            set -e
            trap "echo && exit 1" SIGINT

            mkdir "data_original" && cd "data_original"
            echo "Downloading..."
            curl http://data.law.di.unimi.it/webdata/hollywood-2011/hollywood-2011.graph --output "hollywood-2011.graph"
            curl http://data.law.di.unimi.it/webdata/hollywood-2011/hollywood-2011.properties --output "hollywood-2011.properties"
            cd ".."
        )
        if [ $? -ne 0 ]; then
            echo "Data download failed. Exiting."
            rm -rf "data_original"
            exit 1
        fi
    fi

    # prepare data
    (
        set -e
        trap "echo && exit 1" SIGINT

        # no error if results dir already exists
        mkdir "data_prepared" "results" 2> /dev/null || true

        echo "Converting Webgraph Graph to SNAP Graph ..."
        echo "Cloning Web2Snap repository..."
        git clone https://github.com/phoeinx/Web2Snap.git &> /dev/null
        cd "Web2Snap"
        echo "Building Web2Snap converter ..."
        mvn package &> /dev/null
        echo "Converting graph... (It's again a big graph and time for a coffee break.)"
        java -cp target/Web2Snap-1.0-SNAPSHOT-jar-with-dependencies.jar org.zork.Web2Snap "../data_original/hollywood-2011" "../data_prepared/hollywood-2011.txt" > /dev/null
        echo "Successfully converted graph!"
        cd ".."
        echo "Deleting Web2Snap repository ..."
        rm -rf "Web2Snap"

        echo "Preparing analysis data..."
        echo "Downloading id look-up file to match actor id with actor name && Academy Award Nominee List from Wikipedia ..."
        python download_analysis_data.py "./results/hollywood-2011-ids.txt" "./results/academy_award_nominees.csv"
    )
    if [ $? -ne 0 ]; then
        echo "Data preparation failed. Exiting."
        rm -rf "data_prepared"
        rm -rf "results/hollywood-2011-ids.txt" "results/academy_award_nominees.csv"
        rm -rf "Web2Snap"
        exit 1
    fi
fi
