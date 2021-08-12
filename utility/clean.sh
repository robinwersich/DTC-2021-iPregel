#!/bin/bash

LIGRA_DIR="ligra"

cd $(dirname "$0")/..

# help text
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "" ]; then
    echo "usage: $0 OPTION"
    echo "possible OPTIONs:"
    echo "--bin: remove iPregel binaries"
    echo "--benchmarks: remove benchmark results"
    echo "--results: remove analysis results"
    echo "--data-prepared: remove preprocessed data, but keep downloads"
    echo "--data-downloads: remove original data downloads, but keep preprocessed data"
    echo "--data: remove all graph data"
    echo "--uninstall: remove all previously mentioned data and uninstall ligra and networkit"
    exit
fi

if [ "$1" = "--bin" ] || [ "$1" = "--uninstall" ]; then
    make clean -C "iPregel" > /dev/null
fi

if [ "$1" = "--benchmarks" ] || [ "$1" = "--uninstall" ]; then
    rm -rf "benchmark_results"
fi

if [ "$1" = "--results" ] || [ "$1" = "--uninstall" ]; then
    rm -rf analyses/*/results
fi

if [ "$1" = "--data-prepared" ] || [ "$1" = "--data" ] || [ "$1" = "--uninstall" ]; then
    rm -rf analyses/*/data_prepared
fi

if [ "$1" = "--data-downloads" ] || [ "$1" = "--data" ] || [ "$1" = "--uninstall" ]; then
    rm -rf analyses/*/data_original
fi

if [ "$1" = "--uninstall" ]; then
    rm -rf .venv
    rm -rf "../$LIGRA_DIR"
fi
