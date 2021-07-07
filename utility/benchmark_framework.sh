#!/bin/bash

# default parameters for benchmarking
THREAD_COUNTS="1"
NUM_REPETITIONS="1"
DO_PREPARE_RUN="true"

# iPregel default parameters
SCHEDULE="dynamic"
CHUNK_SIZE="10"

# derive root dir from benchmark script path
BASE_DIR="$(dirname "$0")/.."

# executable directories
IPREGEL_DIR="$BASE_DIR/bin"
NETWORKIT_DIR="$BASE_DIR/networkit"

trap "exit SIGINT" SIGINT

# for each THREAD_COUNT sets NUM_THREADS accordingly and
# runs the given command NUM_REPETITION times
multirun() {
    if "$DO_PREPARE_RUN"; then
        echo "Unmeasured run to load data into memory..."
        # ignore memory output
        MEMORY_FILE="/dev/null"
        # execute with max threads to be fast
        NUM_THREADS=${THREAD_COUNTS: -1}
        $1 &> /dev/null || return 1
    fi

    for NUM_THREADS in $THREAD_COUNTS; do
        BENCHMARK_NAME="$BENCHMARK_DIR/${GRAPH_NAME}_${NUM_THREADS}"
        TIME_FILE="${BENCHMARK_NAME}_time.txt"
        MEMORY_FILE="${BENCHMARK_NAME}_memory.txt"
        # empty benchmark files
        true > "$TIME_FILE"; true > "$MEMORY_FILE"
        echo -n "Running $NUM_REPETITIONS times with thread count $NUM_THREADS: "
        for i in $(seq "$NUM_REPETITIONS"); do
            $1 1>> "$TIME_FILE" 2> /dev/null || return 1
            echo -n "#"
        done
        echo
    done
}

# sets variables according to the given parameters
parseArguments() {
    FRAMEWORK=$1
    PROGRAM=$2
    GRAPH=$3
    shift; shift; shift
    ADDITIONAL_PARAMS=("$@")

    PROGRAM_NAME="$(basename "${PROGRAM%.py}")"
    GRAPH_NAME="$(basename "${GRAPH%.txt}")"
    BENCHMARK_DIR="$BASE_DIR/benchmark_results/$FRAMEWORK/$PROGRAM_NAME"
    RESULT_DIR="$(dirname "$GRAPH")/../results"
    RESULT_FILE="$RESULT_DIR/${FRAMEWORK}_${PROGRAM_NAME}_${GRAPH_NAME}.txt"

    # create non-existend directories
    mkdir -p "$BENCHMARK_DIR" 2> /dev/null || true
    mkdir -p "$RESULT_DIR" 2> /dev/null || true
}

iPregelSingleRun() {
    /usr/bin/time -f "%M" -o "$MEMORY_FILE" -a "$IPREGEL_DIR/$PROGRAM" "${GRAPH%.txt}" "$RESULT_FILE" "$NUM_THREADS" "$SCHEDULE" "$CHUNK_SIZE" "${ADDITIONAL_PARAMS[@]}" && echo
}

# runs an iPregel executable located in IPREGEL_DIR, expects <program name> <graph> as inputs
iPregel() {
    parseArguments "iPregel" $@
    echo "Benchmarking iPregel program $PROGRAM_NAME with graph $GRAPH_NAME..."
    # convert graph if not already done
    CONVERSION_ERR="$("$BASE_DIR/utility/Snap2iPregel.sh" "$GRAPH" 2>&1 1> /dev/null)"
    if [ $? -ne 0 ]; then
        echo -e "Benchmark failed:\n\e[31m$CONVERSION_ERR\e[0m"
    else
        multirun iPregelSingleRun || echo -e "Benchmark failed:\n\e[31m$(iPregelSingleRun 2>&1)\e[0m"
    fi
    echo
}

networkitSingleRun() {
    /usr/bin/time -f "%M" -o "$MEMORY_FILE" -a python "$NETWORKIT_DIR/$PROGRAM.py" "$GRAPH" "$RESULT_FILE" --numThreads "$NUM_THREADS" "${ADDITIONAL_PARAMS[@]}"
}

# runs a networkit executable located in NETWORKIT_DIR, expects <program name> <graph> as inputs
networkit() {
    parseArguments "networkit" $@
    echo "Benchmarking networkit program $PROGRAM_NAME with graph $GRAPH_NAME..."
    multirun networkitSingleRun || echo -e "Benchmark failed:\n\e[31m$(networkitSingleRun 2>&1)\e[0m"
    echo
}

source "$BASE_DIR/.venv/bin/activate"
