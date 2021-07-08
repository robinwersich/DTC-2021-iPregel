import argparse
import re
import sys
from os import path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="path to iPregel benchmark output file")
    parser.add_argument("output", help="path to target csv file")
    args = parser.parse_args()

    if not path.exists(args.input):
        print(f"The given input file '{args.input}' doesn't exist.", file=sys.stderr)
        return 1

    with open(args.input, 'r') as input_file:
        results = re.findall(r"InitialisationTime:\s*([\d\.]+)[^*]*Total time of supersteps:\s*([\d\.]+)[^*]*DumpingTime:\s*([\d\.]+)", input_file.read(), re.DOTALL)
    with open(args.output, 'w') as output_file:
        for load_time, calc_time, dump_time in results:
            print(f"{load_time}\t{calc_time}\t{dump_time}", file=output_file)

if __name__ == "__main__":
    main()