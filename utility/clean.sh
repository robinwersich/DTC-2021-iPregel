#!/bin/bash

cd $(dirname "$0")/..

# help text
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "" ]; then
    echo "usage: $0 [--bin] [--benchmarks] [--results] [--data-prepared] [--data-downloads] [--data] [--all]"
    exit
fi

if [ "$1" = "--bin" ] || [ "$1" = "--all" ]; then
    rm -rf "bin"
fi

if [ "$1" = "--benchmarks" ] || [ "$1" = "--all" ]; then
    rm -rf "benchmark_results"
fi

if [ "$1" = "--results" ] || [ "$1" = "--all" ]; then
    rm -rf analyses/*/results
fi

if [ "$1" = "--data-prepared" ] || [ "$1" = "--data" ] || [ "$1" = "--all" ]; then
    rm -rf analyses/*/data_prepared
fi

if [ "$1" = "--data-downloads" ] || [ "$1" = "--data" ] || [ "$1" = "--all" ]; then
    rm -rf analyses/*/data_original
fi
