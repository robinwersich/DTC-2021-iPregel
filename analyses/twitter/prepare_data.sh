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
            curl https://snap.stanford.edu/data/higgs-activity_time.txt.gz --output higgs-activity.txt.gz
            echo "Extracting..."
            gzip -d higgs-activity.txt.gz

            echo "Downloading friends / follower graph .."
            curl https://snap.stanford.edu/data/higgs-social_network.edgelist.gz --output higgs-social-network.txt.gz
            echo "Extracting..."
            gzip -d higgs-social-network.txt.gz
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

        cd "data_prepared"
        echo "Removing timestamps, interaction types, self-interactions and duplicates..."
        python ../preprocess_twitter_network.py "../data_original/higgs-activity.txt" "./higgs-twitter.txt"

        cd "../results"
        echo "Calculating classic node importance score: Follower Count..."
        python ../calculate_follower_count.py "../data_original/higgs-social-network.txt"

        cd ".."
        GRAPH_NAME="data_prepared/higgs-twitter"
        echo "Creating reversed version of graph..."
        ../../utility/reverse_edges.sh < "${GRAPH_NAME}.txt" > "${GRAPH_NAME}_reversed.txt"
        echo "Creating undirected version of graph..."
        cat "${GRAPH_NAME}.txt" "${GRAPH_NAME}_reversed.txt" | sort -S 50% -n | uniq > "${GRAPH_NAME}_undirected.txt"
    )
    if [ $? -ne 0 ]; then
        echo -e "\e[31mData preparation failed. Aborting.\e[0m"
        rm -rf "data_prepared"
        rm -rf "results"
        exit 1
    fi
fi

