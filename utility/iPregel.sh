#!/bin/bash

BASEDIR=$(dirname "$0")

# help text
if [ $1 = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "" ]; then
    echo "This is a helper script to make executing iPregel programs more straightforward."
    echo
    echo "usage: $0 <iPregel program> <input graph> <...program arguments (except in and out path)>"
    exit
fi

if [ $# -lt 2 ]; then
    echo "Too few arguments. Expected at least a program path and an input graph (refer to --help)."
    exit
fi

if [ ! -f "$1" ]; then
    echo "iPregel program '$1' wasn't found."
elif [ ! -f "$2" ]; then
    echo "Graph '$2' wasn't found."
else
    PROGRAM="$1"
    GRAPH_IN="$2"
    GRAPH_OUT="${2%.txt}_$(basename "$PROGRAM").txt"
    shift
    shift
    "$PROGRAM" "$($BASEDIR/Snap2iPregel.sh "$GRAPH_IN")" "$GRAPH_OUT" "$@"
fi
