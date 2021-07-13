import sys
import argparse
from os import path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="path to unnormalized pagerank results")
    parser.add_argument("output", nargs='?', help="path to target file for normalized results")
    args = parser.parse_args()

    if not path.exists(args.input):
        print(f"The given input file '{args.input}' doesn't exist.", file=sys.stderr)
        return 1

    with open(args.input, 'r') as input_file:
        sum = 0
        results = []
        for line in input_file:
            vertex, pagerank = line.strip().split("\t")
            sum += float(pagerank)
            results.append((vertex, float(pagerank)))

    input_root, input_ext = path.splitext(args.input)
    output_path = args.output or f"{input_root}_normalized{input_ext}"
    with open(output_path, 'w') as output_file:
        for vertex, pagerank in results:
            print(f"{vertex}\t{(pagerank / sum):.20f}", file=output_file)

if __name__ == "__main__":
    main()
