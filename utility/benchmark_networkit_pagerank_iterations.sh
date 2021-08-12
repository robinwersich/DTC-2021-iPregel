#!/bin/bash

# load the benchmarkign framework and go to root directory
source "$(dirname "$0")/benchmark_framework.sh"
cd $BASE_DIR

# set these according to your needs
THREAD_COUNTS="36"
NUM_REPETITIONS="1"

SCHEDULE=dynamic
CHUNK_SIZE=256

# comment in if you don't want to do an extra run to load the data into RAM
DO_PREPARE_RUN=false

# ----- networkit programs -----

networkit pagerank analyses/citation/data_prepared/author-citation.txt --directed --printNumIterations
networkit pagerank analyses/twitter/data_prepared/higgs-activity_time.txt --directed --printNumIterations
networkit pagerank analyses/stackoverflow/data_prepared/stackoverflow.txt --directed --printNumIterations
networkit pagerank analyses/imdb/data_prepared/hollywood-2011.txt --undirected --printNumIterations
