#!/bin/bash

# this script is not mainly about the benchmarking but more about the results,
# as we have no iPregel implementation to compare with

# load the benchmarkign framework and go to root directory
source "$(dirname "$0")/benchmark_framework.sh"
cd $BASE_DIR

# set these according to your needs
THREAD_COUNTS="128"
NUM_REPETITIONS="1"

# comment in if you don't want to do an extra run to load the data into RAM
DO_PREPARE_RUN=false

# change iPregel parameters if you want: SCHEDULE and CHUNK_SIZE

networkit betweenness_centrality analyses/citation/data_prepared/author-citation_reversed.txt --directed
networkit closeness_centrality analyses/citation/data_prepared/author-citation_reversed.txt --directed

networkit betweenness_centrality analyses/twitter/data_prepared/higgs-activity_time_reversed.txt --directed
networkit closeness_centrality analyses/twitter/data_prepared/higgs-activity_time_reversed.txt --directed

networkit betweenness_centrality analyses/stackoverflow/data_prepared/stackoverflow_reversed.txt --directed
networkit closeness_centrality analyses/stackoverflow/data_prepared/stackoverflow_reversed.txt --directed

networkit betweenness_centrality analyses/imdb/data_prepared/hollywood-2011.txt --undirected
networkit closeness_centrality analyses/imdb/data_prepared/hollywood-2011.txt --undirected
