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
    curl https://snap.stanford.edu/data/sx-stackoverflow.txt.gz --output stackoverflow-original.txt.gz
    echo "Extracting..."
    gzip -d stackoverflow-original.txt.gz
    echo "Removing timestamps, reversing edges and removing duplicates..."
    echo "This is a huge graph, so it may take quite a while - relax."
    python ../reverse_remove_timestamp.py stackoverflow-original.txt | sort | uniq > stackoverflow.txt
    rm stackoverflow-original.txt
)
if [ $? -ne 0 ]; then
    echo "Data preparation failed. Exiting."
    rm -rf "data"
    exit 1
fi
