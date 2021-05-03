# Dissecting The Complex - iPregel Crew



## Task

![image-20210429141701472](/Users/tam/Library/Application Support/typora-user-images/image-20210429141701472.png)

- What exactly does graph preprocessing mean?
- Why is iPregel interesting to Katharina 

## Organisation

- How to share resources?
  - Sources (papers, articles, summaries etc.) => Drive
- Git Repo
  - 1. Fork of iPregel, playground and testing purposes



## Preliminary tasks / Considerations

- What data / networks do we want to use ? What would be exciting to find out ? It would be cool to work on an exciting question as well, now that we have the resources. Which real world situations could be mapped to graphs and have interesting properties? (Ideally should make sense to use single-source shortest path, PageRank, connected components)
  - Possible network sources:
    - https://snap.stanford.edu/data/
    - https://snap.stanford.edu/biodata/index.html
    - https://project-awesome.org/briatte/awesome-network-analysis
    - https://en.wikipedia.org/wiki/List_of_datasets_for_machine_learning_research
    - https://archive.ics.uci.edu/ml/datasets.php
    - https://www.openml.org/search?type=data
    - https://github.com/awesomedata/awesome-public-datasets
  - What are common techniques to gather information from graphs?
    - PageRank
    - SSSP
    - Connected Components
  - What interesting real-world graph analyses do exist? (Inspiration)
  - What topics / domains do we find interesting?
    - climate data
    - causal inference
- What do we do with results? How to interpret them?
  - Visualization, further computation etc.
- How to check for correct implementation?
  - Small scale 
- Implement own vertex-centric algorithms => leverage alleged ease of programming new vertex-centric algorithms
  - Fitting to selected network
- Compare iPregel parallelized graph algorithms with standard graph algorithms ("When does it make sense to use parallel graph algorithms?")
  - Hypothesis: From a certain number of nodes it starts making sense, but is this already the case for our graph sizes?
  - Literature ?
- Further optimize iPregel
- Distributed vs. shared memory parallelism 
  - iPregel: shared memory, Pregel: distributed (?)
- Overview over (vertex-centric) graph processing networks (goal size, distributed vs. shared memory)
  - Apache Giraph, Pregel, Cassovary, 
  - iPregel: Be as performant as Ligra, but keep vertex centered programmability
- Introduction to Benchmarking 
- Introduction to Parallel Computing



## To-Dos

- Fork => Robin
- Drive => Theresa
- Clone and get iPregel / our Fork running
  - Find small networks to test it with
  - Familiarize with vertex-centric programming, implement one standard algorithm
- Find interesting data sets