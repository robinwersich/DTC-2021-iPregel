# For some analyses we need the undirected version of the graph instead of the directed
# This script adds the reversed edge for each directed edge, it does not handle duplicates
# The output is printed to stdout

import sys
from os import path
import re


def main():
    if not input_valid():
        return

    with open(sys.argv[1], 'r') as input_edges:
        for line in input_edges:
            # ignore comments
            if line.startswith("#") or line == "\n":
                continue
            line = line.rstrip('\n')

            vertex1, vertex2 = re.split(r"[\t ]+", line)
            edge = f"{vertex1}\t{vertex2}"
            reversed_edge = f"{vertex2}\t{vertex1}"
            print(edge)
            print(reversed_edge)

def input_valid():
    """checks if the correct parameters were given and prints error message if not"""

    valid = True
    if len(sys.argv) <= 1:
        valid = False
    else:
        if not path.exists(sys.argv[1]):
            print(f"The given graph file '{sys.argv[1]}' doesn't exist.")
            valid = False

    if not valid:
        print(f"usage: {sys.argv[0]} <graph>")
    return valid

if __name__ == "__main__":
    main()
