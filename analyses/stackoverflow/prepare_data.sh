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
            trap "echo '\n' && exit 1" SIGINT

            mkdir "data_original"
            echo "Downloading..."
            curl https://snap.stanford.edu/data/sx-stackoverflow.txt.gz --output "data_original/stackoverflow-original.txt.gz"
            echo "Extracting..."
            gzip -d "data_original/stackoverflow-original.txt.gz"
        )
        if [ $? -ne 0 ]; then
            echo "Data download failled. Exiting."
            rm -rf "data_original"
            exit 1
        fi
    fi

    # prepare data
    (
        set -e
        trap "echo '\n' && exit 1" SIGINT

        mkdir "data_prepared"
        echo "Removing timestamps, reversing edges and removing duplicates..."
        echo "This is a huge graph, so it may take quite a while - relax."
        python reverse_remove_timestamp.py "data_original/stackoverflow-original.txt" | sort | uniq > "data_prepared/stackoverflow.txt"
    )
    if [ $? -ne 0 ]; then
        echo "Data preparation failled. Exiting."
        rm -rf "data_prepared"
        exit 1
    fi
fi
