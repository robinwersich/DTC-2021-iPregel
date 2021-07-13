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
        GRAPH_NAME="data_prepared/author-citation"
        python papersToUsers.py "data_original/paper-citation.txt" "data_original/metadata" "$GRAPH_NAME.txt" "results/author-metadata.txt"

        echo "Creating reversed version of graph..."
        ../../utility/reverse_edges.sh < "${GRAPH_NAME}.txt" > "${GRAPH_NAME}_reversed.txt"
        echo "Creating undirected version of graph..."
        cat "${GRAPH_NAME}.txt" "${GRAPH_NAME}_reversed.txt" | sort -S 50% -n | uniq > "${GRAPH_NAME}_undirected.txt"
    )
    if [ $? -ne 0 ]; then
        echo "Data preparation failed. Aborting."
        rm -rf "data_prepared"
        rm -f "results/author-metadata.txt"
        exit 1
    fi
fi
