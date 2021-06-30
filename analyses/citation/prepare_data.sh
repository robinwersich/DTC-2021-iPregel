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
    curl https://snap.stanford.edu/data/cit-HepTh.txt.gz --output paper-citation.txt.gz
    curl https://snap.stanford.edu/data/cit-HepTh-abstracts.tar.gz --output paper-metadata.tar.gz
    echo "Extracting..."
    gzip -d paper-citation.txt.gz
    mkdir metadata
    tar -xzf paper-metadata.tar.gz -C metadata --strip-components=1
    rm paper-metadata.tar.gz
    echo "Converting paper graph to author graph..."
    python ../papersToUsers.py paper-citation.txt metadata author-citation.txt author-metadata.txt
    rm paper-citation.txt
    rm -r metadata
)
if [ $? -ne 0 ]; then
    echo "Data preparation failed. Exiting."
    rm -rf "data"
    exit 1
fi
