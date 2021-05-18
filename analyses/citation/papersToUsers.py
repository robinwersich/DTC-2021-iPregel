#!/usr/bin/python

# Expected metadata format contains following line:
# Authors: Author1, Author2, ... and Author3

import sys
import os
from os import path
import re
from collections import defaultdict


def main():
    if not input_valid():
        return
    
    authors_papers_dict = get_authors_papers_dict(sys.argv[1])

    print(f"\n{len(authors_papers_dict)} authors in total")
    for author, papers in sorted(authors_papers_dict.items()):
        print(f"{author}: {papers}")

def get_authors_papers_dict(metadata_dir: str) -> dict[str, int]:
    fileending = ".abs"
    author_pattern = re.compile(r'From:\s*"?(.*)"?<.*>')

    authors_papers_dict = defaultdict(list)

    for entry in os.scandir(metadata_dir):
        if not entry.is_file or not entry.path.endswith(fileending):
            continue
        paper_id = int(entry.name.removesuffix(fileending))
        with open(entry.path, 'r') as file:
            for line in file:
                match = author_pattern.match(line)
                if match:
                    author = match.group(1)
                    authors_papers_dict[author].append(paper_id)

    return authors_papers_dict


def input_valid() -> bool:
    if len(sys.argv) <= 1:
        print("You need to provide a directory path.")
    elif not path.exists(sys.argv[1]):
        print("The given directory dosn't exist.")
    else:
        return True
    return False
    

if __name__ == "__main__":
    main()