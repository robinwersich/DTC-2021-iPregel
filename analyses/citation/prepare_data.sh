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
            curl https://snap.stanford.edu/data/cit-HepTh.txt.gz --output "paper-citation.txt.gz"
            curl https://snap.stanford.edu/data/cit-HepTh-abstracts.tar.gz --output "paper-metadata.tar.gz"
            echo "Extracting..."
            gzip -d "paper-citation.txt.gz"
            mkdir "metadata"
            tar -xzf "paper-metadata.tar.gz" -C "metadata" --strip-components=1
            rm paper-metadata.tar.gz
            cd ".."
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

        echo "Converting paper graph to author graph..."
        # no error if results dir already exists
        mkdir "data_prepared" "results" 2> /dev/null || true
        python papersToUsers.py "data_original/paper-citation.txt" "data_original/metadata" "data_prepared/author-citation.txt" "results/author-metadata.txt"

        echo "Creating undirected version of graph..."
        python ../../utility/convert_to_undirected_graph.py "data_prepared/author-citation.txt" | uniq > "data_prepared/undirected-author-citation.txt"
    )
    if [ $? -ne 0 ]; then
        echo "Data preparation failed. Aborting."
        rm -rf "data_prepared"
        rm -f "results/author-metadata.txt"
        exit 1
    fi
fi
