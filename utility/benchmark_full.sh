#!/bin/bash

# load the benchmarkign framework and go to root directory
source "$(dirname "$0")/benchmark_framework.sh"
cd $BASE_DIR

# set these according to your needs
THREAD_COUNTS="1 2 4 8 16 18 32 36"
NUM_REPETITIONS="100"

SCHEDULE=dynamic
CHUNK_SIZE=256

# comment in if you don't want to do an extra run to load the data into RAM
# DO_PREPARE_RUN=false

# ----- iPregel programs -----
iPregel cc_single_broadcast_spread_32 analyses/citation/data_prepared/author-citation_undirected.txt undirected
iPregel cc_single_broadcast_spread_32 analyses/twitter/data_prepared/higgs-activity_time_undirected.txt undirected
iPregel cc_single_broadcast_spread_32 analyses/stackoverflow/data_prepared/stackoverflow_undirected.txt undirected
iPregel cc_single_broadcast_spread_32 analyses/imdb/data_prepared/hollywood-2011.txt undirected

# iPregel doesn't implement terminating PageRank based on convergence of results
# therefore we take the number of iterations the networkit program needed to converge
iPregel pagerank_single_broadcast_32 analyses/citation/data_prepared/author-citation.txt 63
iPregel pagerank_single_broadcast_32 analyses/twitter/data_prepared/higgs-activity_time.txt 88
iPregel pagerank_single_broadcast_32 analyses/stackoverflow/data_prepared/stackoverflow.txt 44
iPregel pagerank_single_broadcast_32 analyses/imdb/data_prepared/hollywood-2011.txt 41

iPregel sssp_single_broadcast_spread_32 analyses/citation/data_prepared/author-citation_reversed.txt 398 directed
iPregel sssp_single_broadcast_spread_32 analyses/twitter/data_prepared/higgs-activity_time_reversed.txt 1503 directed
iPregel sssp_single_broadcast_spread_32 analyses/stackoverflow/data_prepared/stackoverflow_reversed.txt 22656 directed
iPregel sssp_single_broadcast_spread_32 analyses/imdb/data_prepared/hollywood-2011.txt 1765703 undirected


# ----- networkit programs -----
networkit connected_components analyses/citation/data_prepared/author-citation_undirected.txt --undirected
networkit connected_components analyses/twitter/data_prepared/higgs-activity_time_undirected.txt --undirected
networkit connected_components analyses/stackoverflow/data_prepared/stackoverflow_undirected.txt --undirected
networkit connected_components analyses/imdb/data_prepared/hollywood-2011.txt --undirected

networkit pagerank analyses/citation/data_prepared/author-citation.txt --directed
networkit pagerank analyses/twitter/data_prepared/higgs-activity_time.txt --directed
networkit pagerank analyses/stackoverflow/data_prepared/stackoverflow.txt --directed
networkit pagerank analyses/imdb/data_prepared/hollywood-2011.txt --undirected

networkit sssp analyses/citation/data_prepared/author-citation_reversed.txt --startnode 398 --directed
networkit sssp analyses/twitter/data_prepared/higgs-activity_time_reversed.txt --startnode 1503 --directed
networkit sssp analyses/stackoverflow/data_prepared/stackoverflow_reversed.txt --startnode 22656 --directed
networkit sssp analyses/imdb/data_prepared/hollywood-2011.txt --startnode 1765703 --undirected
