#!/bin/bash

# load the benchmarkign framework and go to root directory
source "$(dirname "$0")/benchmark_framework.sh"
cd $BASE_DIR

# set these according to your needs
THREAD_COUNTS="1 2"
NUM_REPETITIONS="2"

# comment in if you don't want to do an extra run to load the data into RAM
# DO_PREPARE_RUN=false

# ----- iPregel programs -----
iPregel cc_32 analyses/citation/data_prepared/author-citation.txt directed
iPregel cc_32 analyses/twitter/data_prepared/prepared_higgs-activity_time.txt directed
iPregel cc_32 analyses/stackoverflow/data_prepared/stackoverflow.txt directed
iPregel cc_32 analyses/imdb/data_prepared/hollywood-2011.txt undirected

iPregel pagerank_32 analyses/citation/data_prepared/author-citation.txt 10
iPregel pagerank_32 analyses/twitter/data_prepared/prepared_higgs-activity_time.txt 10
iPregel pagerank_32 analyses/stackoverflow/data_prepared/stackoverflow.txt 10
iPregel pagerank_32 analyses/imdb/data_prepared/hollywood-2011.txt 10

iPregel sssp_32 analyses/citation/data_prepared/author-citation.txt 0 directed
iPregel sssp_32 analyses/twitter/data_prepared/prepared_higgs-activity_time.txt 0 directed
iPregel sssp_32 analyses/stackoverflow/data_prepared/stackoverflow.txt 0 directed
iPregel sssp_32 analyses/imdb/data_prepared/hollywood-2011.txt 0 undirected


# ----- networkit programs -----
networkit connected_components analyses/citation/data_prepared/author-citation.txt --directed
networkit connected_components analyses/twitter/data_prepared/prepared_higgs-activity_time.txt --directed
networkit connected_components analyses/stackoverflow/data_prepared/stackoverflow.txt --directed
networkit connected_components analyses/imdb/data_prepared/hollywood-2011.txt --undirected

networkit pagerank analyses/citation/data_prepared/author-citation.txt --directed
networkit pagerank analyses/twitter/data_prepared/prepared_higgs-activity_time.txt --directed
networkit pagerank analyses/stackoverflow/data_prepared/stackoverflow.txt --directed
networkit pagerank analyses/imdb/data_prepared/hollywood-2011.txt --undirected

networkit sssp analyses/citation/data_prepared/author-citation.txt --startnode 0 --directed
networkit sssp analyses/twitter/data_prepared/prepared_higgs-activity_time.txt --startnode 0 --directed
networkit sssp analyses/stackoverflow/data_prepared/stackoverflow.txt --startnode 0 --directed
networkit sssp analyses/imdb/data_prepared/hollywood-2011.txt --startnode 0 --undirected
