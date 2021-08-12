# Complex Networks 2021 - iPregel

This repository is part of the iPregel project during the Complex Networks Seminar in 2021.
It captures the [iPregel repository](https://github.com/capellil/iPregel) in the state of June 24th, 2021 in the `iPregel` directory with modifications made by us.

## Goal

We want to to examine the performance and usability of iPregel compared to networkit, a standard graph library.
In addition, we want to analyse 4 networks of our choice in terms of node importance measures and compare the results with classical node importance measures.

## How to reproduce our results

### Requirements

- A running Linux system
- Git & Make
- C/C++11 compliant compiler (e.g. gcc/g++)
- Python 3.8 or higher (for networkit and preprocessing)
- The Python venv module or virtualenv
- Java and Maven (for conversion of the IMDb Dataset)
- R (for data analysis)

### Setup

1. Clone this repository
2. Execute `utility/setup.sh`.
   This will do the following things (if you run this script again, it will recognize which steps were already executed and skip those):
   - compile the iPregel binaries
   - clone and compile the [Ligra](https://github.com/jshun/ligra) SNAP to Binary conversion utility (needed to convert SNAP datasets to iPregel format)
   - create a virtual python environment and install networkit and other python dependencies (this can take a while)
   - download and preprocess our datasets (you can skip each dataset using `^C`)

### Executing our benchmarks

The benchmarks are configured to run on a machine with 36 threads. They can be run on any other machine, but you might want to adjust the thread counts.
In the `utility` folder, you find two files you need to execute to get all of our results:
- `benchmark_full.sh`: Performance Comparison. Benchmarks SSSP, Connected Components and Pagerank for both iPregel and networkit (several runs each)
- `benchmark_analysis.sh`: Graph analysis. Runs Betweenness and Closeness Centrality on all graphs (only networkit, only 1 iteration)

You will find the performance results in the `benchmark_results` folder and the graph analysis results in the `results` folder of the respective graph (`analyses/*`).

You can of course adapt our benchmark scripts to your needs or write your own using the `benchmark_template.sh`

### Running the data analysis

**TODO**

### Single Executions

If you only want to execute a single iPregel or networkit algorithm on a single graph, that's of course also possible we created simple convenience scripts that handle the necessary graph conversion for iPregel, activating the virtual environment for networkit and the name generation for the output file (so you don't have to type it yourself). The usage is as follows:
```bash
# <arguments> must be the arguments required by the program,
# except for input and output path
utility/networkit.sh <program path> <graph path> <arguments>
utility/iPregel.sh <program path> <graph path> <arguments>
```

### Cleanup

If you want to free storage or uninstall this project, refer to `utility/clean.sh --help`
