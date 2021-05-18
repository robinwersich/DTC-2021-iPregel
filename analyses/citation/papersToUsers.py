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

    print(f"{len(authors_papers_dict)} authors in total\n")
    for author, papers in sorted(authors_papers_dict.items()):
        print(f"{author}: {papers}")

def remove_parentheses(s: str) -> str:
    """removes every parenthesized expression from the string"""

    new_string = ""
    parentheses_count = 0
    for c in s:
        if parentheses_count < 0:
            raise RuntimeError(f"malformed parentheses: {s}\n")
        elif c == '(':
            parentheses_count += 1
        elif c == ')':
            parentheses_count -= 1
        elif parentheses_count == 0:
            new_string += c

    return new_string

def get_authors_papers_dict(metadata_dir: str) -> dict[str, int]:
    authors_papers_dict = defaultdict(list)

    for entry in os.scandir(metadata_dir):
        if not entry.is_file or not entry.path.endswith(".abs"):
            continue
        paper_id = int(entry.name.removesuffix(".abs"))

        file = open(entry.path, 'r')
        file_contents = file.read()
        file.close()

        # find the authors string inside the meta info
        # it can be multi-line, so we search until the first non-indented line
        author_str = re.search(r"Authors?:\s*(.*(?:\n\s+.*)*)", file_contents).group(1).replace('\n', '')
        # first remove parenthesized info which might contain annoying commas
        author_str = remove_parentheses(author_str)
        # authors are separated by ", " or "and" or both with variable additional whitespace
        authors = re.split(r"\s*(?:,\s+and |,| and )\s*", author_str)
        for author in authors:
            author = author.strip()
            if author == "": continue
            authors_papers_dict[author].append(paper_id)

    return authors_papers_dict


def input_valid() -> bool:
    if len(sys.argv) <= 1:
        print("You need to provide a directory path.")
    elif not path.exists(sys.argv[1]):
        print("The given directory doesn't exist.")
    else:
        return True
    return False
    

if __name__ == "__main__":
    main()