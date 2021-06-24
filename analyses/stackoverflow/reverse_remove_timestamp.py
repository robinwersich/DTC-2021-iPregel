#!/usr/bin/python

# The input graph contains edges from the interacting user to the destination user.
# We want to give highly interacting users more importance, so we reverse the edges.
# Also, we remove the timestamps from the edges and reduce duplicate edges to a single one.

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
            interacting_user, target_user = re.split(r"[\t ]+", line)[:2]
            if (interacting_user != target_user):
                print(f"{target_user}\t{interacting_user}")

def input_valid() -> bool:
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
