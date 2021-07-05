#!/bin/bash

# set these according to your needs
THREAD_COUNTS="1 2 4 8"
NUM_REPETITIONS="5"

# comment in if you don't want to do an extra run to load the data into RAM
# DO_PREPARE_RUN=false

# change iPregel parameters if you want: SCHEDULE and CHUNK_SIZE

# load the benchmarkign framework and go to root directory
source "$(dirname "$0")/benchmark_framework.sh"
cd $BASE_DIR

# ----- iPregel programs -----
# iPregel <program name> <graph path> ...<additional arguments>


# ----- networkit programs -----
# networkit <program name> <graph path> ...<additional arguments>
