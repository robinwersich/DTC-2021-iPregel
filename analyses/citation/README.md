# Scientist Node importance vs. h-index

## Analysed Graph
The [Arxiv HEP-TH (high energy physics theory) citation graph](https://snap.stanford.edu/data/cit-HepTh.html) is from the e-print arXiv and covers all the citations within a dataset of 27,770 papers with 352,807 edges. If a paper i cites paper j, the graph contains a directed edge from i to j. If a paper cites, or is cited by, a paper outside the dataset, the graph does not contain any information about this.

The data covers papers in the period from January 1993 to April 2003 (124 months). It begins within a few months of the inception of the arXiv, and thus represents essentially the complete history of its HEP-TH section.

## Goal
We want to generate a graph of scientists and their references between each other. On this graph we will run multiple node importance algorithms and compare them to the classic importance score for scientists, the **h-index**. We will generate the latter from the source graph in order to make it comparable (closed world assumption)

## Preprocessing
- we use the provided node metadata to extract the authors for each paper using a python script
- we create a new graph with authors as nodes, where the graph contains a directed edge from A to B if author A has a paper that cites a paper from author B
- we calculate the h-index for every author using the previously gathered information about which papers they authored and the in-degree of each paper in the original graph as their number of references
