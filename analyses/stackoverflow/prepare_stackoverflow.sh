#!/usr/bin/sh

if [ $# -lt 2 ]; then
    echo "usage: $0 <input graph> <output graph>"
    exit
fi

# first remove timestamps and reverse edges using python
# then eliminate duplicate edges using shell tools
./reverse_remove_timestamp.py "$1" | sort | uniq > "$2"
