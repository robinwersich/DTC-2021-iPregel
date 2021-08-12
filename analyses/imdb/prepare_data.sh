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
            echo -e "\e[31mData download failed. Aborting.\e[0m"
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

        if [ -x "$(command -v java)" ] && [ -x "$(command -v mvn)" ]; then
            echo "Converting Webgraph Graph to SNAP Graph..."
            cd "WebGraphDecoder"
            echo "Building WebGraphDecoder"
            mvn compile > /dev/null
            echo "Converting graph... (It's again a big graph and time for a coffee break.)"
            mvn exec:java -Dexec.mainClass="it.unimi.dsi.webgraph.BVGraph" -Dexec.args="-o -O -L '$(pwd)/../data_original/hollywood-2011'" > /dev/null
            mvn exec:java -Dexec.mainClass="com.dtc.WebGraphDecoder" -Dexec.args="'$(pwd)/../data_original/hollywood-2011' '$(pwd)/../data_prepared/hollywood-2011.txt'" > /dev/null
            echo "Successfully converted graph!"
            mvn clean > /dev/null
            cd ".."
        else
            echo -e "\e[31mGraph conversion requires java and maven to be installed. Skipping conversion.\e[0m"
            exit 1
        fi

        echo "Preparing analysis data..."
        echo "Downloading id look-up file to match actor id with actor name && Academy Award Nominee List from Wikipedia ..."
        python download_analysis_data.py "./results/hollywood-2011-ids.txt" "./results/academy_award_nominees.csv"
    )
    if [ $? -ne 0 ]; then
        echo -e "\e[31mData preparation failed. Aborting.\e[0m"
        rm -rf "data_prepared"
        rm -rf "results/hollywood-2011-ids.txt" "results/academy_award_nominees.csv"
        rm -rf "WebGraphDecoder/target"
        exit 1
    fi
fi
