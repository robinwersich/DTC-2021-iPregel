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
            
            mkdir data_original && cd data_original
            echo "Downloading..."
            curl https://snap.stanford.edu/data/higgs-activity_time.txt.gz --output higgs-activity_time.txt.gz
            echo "Extracting..."
            gzip -d higgs-activity_time.txt.gz

            echo "Downloading friends / follower graph .."
            curl https://snap.stanford.edu/data/higgs-social_network.edgelist.gz --output higgs-social_network.edgelist.gz
            echo "Extracting..."
            gzip -d higgs-social_network.edgelist.gz
        )
        if [ $? -ne 0 ]; then
            echo "Data download failed. Aborting."
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

        cd "data_prepared"
        echo "Removing timestamps, interaction types, self-interactions and duplicates..."
        python ../preprocess_twitter_network.py "../data_original/higgs-activity_time.txt" "./prepared_higgs-activity_time.txt"

        cd "../results"
        echo "Calculating classic node importance score: Follower Count..."
        python ../calculate_follower_count.py "../data_original/higgs-social_network.edgelist"
    )
    if [ $? -ne 0 ]; then
        echo "Data preparation failed. Aborting."
        rm -rf "data_prepared"
        rm -rf "results"
        exit 1
    fi
fi

