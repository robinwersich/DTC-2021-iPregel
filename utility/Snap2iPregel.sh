#!/bin/bash

BASEDIR=$(dirname "$0")

# help text
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "" ]; then
    echo "This script converts SNAP graphs to a format recognizable by iPregel."
    echo "It uses the converters from the ligra project to do so, thus you will have to install them from"
    echo "https://github.com/jshun/ligra"
    echo
    echo "usage: $0 INFILE | OPTION"
    echo
    echo "INFILE - path to a SNAP graph plain text file"
    echo "OPTION - one of the following:"
    echo "  --help (-h): display this help text"
    echo "  --config (-c) [<SNAPtoAdj path> <adjToBinary path>]:"
    echo "      set where the ligra converters used by this script are located"
    exit
fi

# get converter program paths either from file or user
if [ "$1" = "--config" ] || [ "$1" = "-c" ]; then
    # check input validity
    if [ $# -ne 1 ] && [ $# -ne 3 ]; then
        echo "The config option has to be used either with both executable paths or none (interactive mode)."
        exit 1
    fi

    # read executable paths
    if [ $# -eq 3 ]; then
        snap2adj=$2
        adj2bin=$3
    else
        echo "Please enter where your SNAPtoAdj executable is stored:"
        read snap2adj
        echo "Please enter where your adjToBinary executable is stored:"
        read adj2bin
    fi

    # convert to absolute path
    snap2adj="$(cd "$(dirname "$snap2adj")"; pwd)/$(basename "$snap2adj")"
    adj2bin="$(cd "$(dirname "$adj2bin")"; pwd)/$(basename "$adj2bin")"

    # check executable paths validity
    if [ ! -f "$snap2adj" ]; then echo "'$snap2adj' doesn't exist"; exit; fi
    if [ ! -f "$adj2bin" ]; then echo "'$adj2bin' doesn't exist"; exit; fi

    # write paths to config file
    echo "snap2adj='$snap2adj'" > "$BASEDIR/.s2ipconfig"
    echo "adj2bin='$adj2bin'" >> "$BASEDIR/.s2ipconfig"
    exit
fi

if [ ! -f "$BASEDIR/.s2ipconfig" ]; then
    echo "Please first configure the location of the ligra converters used by this script:"
    echo "$0 --config <SNAPtoAdj executable> <adjToBinary executable>"
    exit 1
else
    source "$BASEDIR/.s2ipconfig"

    # check executable paths validity
    if [ ! -f "$snap2adj" ]; then echo "'$snap2adj' doesn't exist"; rm "$BASEDIR/.s2ipconfig"; exit; fi
    if [ ! -f "$adj2bin" ]; then echo "'$adj2bin' doesn't exist"; rm "$BASEDIR/.s2ipconfig"; exit; fi
fi

if [ $# -ne 1 ]; then
    echo "Too many arguments. Expected a single input file (refer to --help)."
    exit 1
fi

if [ -f "$1" ]; then
    graphName="${1%.txt}"

    # converting to Ligra binary format
    "$snap2adj" "$1" "$graphName.tmp"
    "$adj2bin" "$graphName.tmp" "$graphName.idx" "$graphName.adj" "$graphName.config"

    # converting to iPregel binary format (adding edge count)
    edges=$(sed -n 3p "$graphName.tmp")
    echo -e "\n$edges" >> "$graphName.config"

    #remove tmp files
    rm -f "$graphName.tmp"

    # print path of exported binary graph to be passed to iPregel program
    echo "$graphName"
else
    echo "File '$1' wasn't found."
fi  
