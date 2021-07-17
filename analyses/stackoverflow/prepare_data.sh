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

            mkdir "data_original"
            echo "Downloading..."
            curl https://snap.stanford.edu/data/sx-stackoverflow.txt.gz --output "data_original/stackoverflow-original.txt.gz"
            echo "Extracting..."
            gzip -d "data_original/stackoverflow-original.txt.gz"
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
        echo "Removing timestamps and removing duplicates..."
        echo "This is a huge graph, so it may take quite a while - relax."

        GRAPH_NAME="data_prepared/stackoverflow"
        # remove timestamps, then self loops, then duplicates
        # as people with many interactions have many outgoing edges in this graph, this is the reversed version
        sed -E "s/\s+[0-9]+$//" "data_original/stackoverflow-original.txt" | sed -E "/^([0-9]+)\s+\1$/d" | sort -S 50% -n | uniq > "${GRAPH_NAME}_reversed.txt"
        
        echo "Creating reversed version of graph..."
        ../../utility/reverse_edges.sh < "${GRAPH_NAME}_reversed.txt" > "${GRAPH_NAME}.txt"
        
        echo "Creating undirected version of graph..."
        cat "${GRAPH_NAME}.txt" "${GRAPH_NAME}_reversed.txt" | sort -S 50% -n | uniq > "${GRAPH_NAME}_undirected.txt"

        cd "results"
        # we calculate the interaction count with the reversed graph that has outgoing edges for each interaction on each vertex
        echo "Calculating interaction count of each node ..." 
        python ../calculate_interaction_count.py "../data_prepared/${GRAPH_NAME}_reversed.txt"
    )
    if [ $? -ne 0 ]; then
        echo "Data preparation failed. Aborting."
        rm -rf "data_prepared"
        exit 1
    fi
fi
