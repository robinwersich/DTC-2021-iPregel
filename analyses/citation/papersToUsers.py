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
    
    authors_papers_dict = merge_names(get_authors_papers_dict(sys.argv[1]))

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

def get_authors_papers_dict(metadata_dir: str) -> dict[str, list[int]]:
    """creates a dict mapping author names to a list of paper IDs"""

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
        # after numbers (mostly page count) there are no authors anymore, remove
        author_str = re.sub(r"\d.*$", "", author_str)
        # ignore weird special characters that appear in some names
        author_str = re.sub(r"[\\'`{}\"~]", "", author_str)
        # sometimes a "Jr." suffix is separated by a comma, which messes up our splitting later
        author_str = re.sub(r",\s*(?=jr)", " ", author_str, 0, re.IGNORECASE)
        # authors are separated by "," or "and" or both
        authors = re.split(r",\s+and |,| and ", author_str)
        for author in authors:
            author = author.strip()

            if author == "":
                # meta info that has been removed, no more authors coming
                break
            
            # somtimes there is a dot at the end, remove
            author = re.sub(r"\s*\.$", "", author)
            authors_papers_dict[author].append(paper_id)

    return authors_papers_dict

def get_names(author: str) -> tuple[str, list[str]]:
    """splits an author name into a tuple <lastname, firstnames[]>"""

    # for simplicity, split at dots aswell as dashes (and spaces of course)
    author_names = re.split(r"(?:\.|-)+\s*|(?:\.|-)*\s+", author)
    last_name = author_names.pop()
    # normally the last element is the last name, except for the "Jr." Suffix
    if (last_name.lower() == "jr"):
        last_name = author_names.pop()
        author_names.append("Jr.")
    
    return (last_name, author_names)

def normalize_names(authors_papers_dict: dict[str, list[int]]) -> dict[str, list[int]]:
    normalized_dict = defaultdict(list)
    for name in authors_papers_dict.keys():
        last_name, first_names = get_names(name)
        normalized_name = f"{last_name}, {' '.join(first_names)}"

        normalized_dict[normalized_name].extend(authors_papers_dict[name])
    
    return normalized_dict



def merge_names(authors_papers_dict: dict[str, list[int]]) -> dict[str, list[int]]:
    merged_dict = defaultdict(list)

    for name in authors_papers_dict.keys():
        last_name, first_names = get_names(name)

        # We assume every person to be uniquely identifiable by their last name
        # and first letter of the first name. This is not strictly but mostly true
        # and sufficient for our analysis

        short_name = f"{first_names[0][0].upper()}. {last_name}" if len(first_names) > 0 else last_name
        merged_dict[short_name].extend(authors_papers_dict[name])
    
    return merged_dict

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