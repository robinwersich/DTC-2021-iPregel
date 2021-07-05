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
    
    authors_papers_dict = get_authors_papers_dict(sys.argv[2])

    input_graph = open(sys.argv[1], 'r')
    output_graph = open(sys.argv[3] if len(sys.argv) > 3 else "cit_authors.txt", 'w')
    output_metadata = open(sys.argv[4] if len(sys.argv) > 4 else "author_ids.txt", 'w')
    write_graph_and_metadata(input_graph, output_graph, output_metadata, authors_papers_dict)
    input_graph.close()
    output_graph.close()
    output_metadata.close()

def input_valid():
    """checks if the correct parameters were given and prints error message if not"""

    valid = True
    if len(sys.argv) <= 2:
        valid = False
    else:
        if not path.exists(sys.argv[1]):
            print(f"The given graph file '{sys.argv[1]}' doesn't exist.")
            valid = False
        if not path.exists(sys.argv[2]):
            print(f"The given metadata directory '{sys.argv[2]}' doesn't exist.")
            valid = False

    if not valid:
        print(f"usage: {sys.argv[0]} <graph> <metadata-dir> [<output-graph>] [<output-metadata>]")
    return valid

def write_graph_and_metadata(in_graph, out_graph, out_meta, authors_papers_dict):
    """creates a graph in the form of adjacency lists"""

    authors = list(authors_papers_dict.keys())
    papers_author_ids = authors_papers_to_papers_author_ids(authors_papers_dict)

    graph = [set() for i in range(len(authors))]
    paper_cite_counts = defaultdict(int)

    for line in in_graph:
        # ignore comments
        if line.startswith("#"):
            continue
        from_paper, to_paper = re.split(r"[\t ]+", line)[:2]
        # track paper cite count to calculate h-index later
        paper_cite_counts[int(to_paper)] += 1
        # if paper A cites paper B, every author of A cites every author of B
        # but we remove self references
        for from_author in papers_author_ids[int(from_paper)]:
            for to_author in papers_author_ids[int(to_paper)]:
                if from_author != to_author:
                    graph[from_author].add(to_author)
    
    # write edge list to file
    for from_author in range(len(authors)):
        for to_author in graph[from_author]:
            print(f"{from_author}\t{to_author}", file=out_graph)

    # write metadata (author names and h-index) to file
    print("ID\tname\th-index", file=out_meta)
    print("=========================", file=out_meta)
    for id, author in enumerate(authors):
        # algorithm: sort paper counts decreasing, find sidelength of largest square under plotted curve
        paper_citations = sorted([paper_cite_counts[paper] for paper in authors_papers_dict[author]], reverse=True)
        h_index = 0
        while h_index < len(paper_citations) and paper_citations[h_index] >= h_index + 1:
            h_index += 1
            
        print(f"{id}:\t{author}\t{h_index}", file=out_meta)

def authors_papers_to_papers_author_ids(authors_papers_dict):
    """creates a dict mapping paper ids to author ids"""

    author_ids = {author: id for id, author in enumerate(authors_papers_dict.keys())}
    papers_author_ids = defaultdict(list)
    for author in authors_papers_dict.keys():
        for paper in authors_papers_dict[author]:
            papers_author_ids[paper].append(author_ids[author])
    
    return papers_author_ids

def remove_parentheses(s):
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

def get_authors_papers_dict(metadata_dir):
    """creates a dict mapping author names to a list of paper IDs"""

    authors_papers_dict = defaultdict(list)

    for entry in os.scandir(metadata_dir):
        if not entry.is_file or not entry.path.endswith(".abs"):
            continue
        paper_id = int(entry.name[:-4])

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
            # the names for the same author are not consistent (e.g. different abbreviations)
            # so we try to merge them
            author = normalize_name(author)

            authors_papers_dict[author].append(paper_id)

    return authors_papers_dict

def get_names(author):
    """splits an author name into a tuple <lastname, firstnames[]>"""

    # for simplicity, split at dots aswell as dashes (and spaces of course)
    author_names = re.split(r"(?:\.|-)+\s*|(?:\.|-)*\s+", author)
    last_name = author_names.pop()
    # normally the last element is the last name, except for the "Jr." Suffix
    if (last_name.lower() == "jr"):
        last_name = author_names.pop()
        author_names.append("Jr.")
    
    return (last_name, author_names)

def normalize_name(author):
    """
    This converts an author name to a uniform format in order to merge inconsistent
    spellings of the same name
    """

    last_name, first_names = get_names(author)

    # We assume every person to be uniquely identifiable by their last name
    # and first letter of the first name. This is not strictly but mostly true
    # and sufficient for our analysis
    return f"{first_names[0][0].upper()}. {last_name}" if len(first_names) > 0 else last_name


if __name__ == "__main__":
    main()