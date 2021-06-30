#!/bin/bash

# navigate to root directory
cd "$(dirname "$0")"

if [ -d "data" ]; then
    echo "Data already present."
    exit
fi

( # execute in subshell to catch errors and clean up afterwards
    set -e
    
    mkdir data && cd data
    echo "Downloading..."
    curl https://snap.stanford.edu/data/higgs-activity_time.txt.gz --output higgs-activity_time.txt.gz
    echo "Extracting..."
    gzip -d higgs-activity_time.txt.gz
    echo "Removing timestamps, interaction types, self-interactions and duplicates..."
    python ../preprocess_twitter_network.py higgs-activity_time.txt

    cd .. && mkdir analysis_data && cd analysis_pdata
    echo "Calculating classic node importance score: Follower Count..."
    echo "Downloading friends / follower graph .."
    curl https://snap.stanford.edu/data/higgs-social_network.edgelist.gz --output higgs-social_network.edgelist.gz
    echo "Extracting..."
    gzip -d higgs-social_network.edgelist.gz
    echo "Process graph to extract follower counts ..."
    python ../calculate_follower_count.py higgs-social_network.edgelist
)
if [ $? -ne 0 ]; then
    echo "Data preparation failed. Exiting."
    rm -rf "data"
    exit 1
fi
