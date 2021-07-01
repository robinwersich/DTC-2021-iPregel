import networkit as nk
import sys
import argparse
import timeit

UINT_32_MAX = 4294967295

def print_results(results, output_file, isIntegerResult):
    precision_factor = '.0f' if isIntegerResult else '.20f'
    for vertex_id, result in enumerate(results, start=0):
        # unify infinity representation with iPregel
        if result == sys.float_info.max:
            result = UINT_32_MAX
        print(f"{vertex_id}\t{format(result,precision_factor)}", file=output_file)

parser = argparse.ArgumentParser()

parser.add_argument("input", help="(Relative Path to) graph in edgelist format (e.g. SNAP) to run algorithm on. Default seperator is tab.")
parser.add_argument("output", help="Relative path to name of outputfile.")

parser.add_argument("--numThreads", type=int, dest='numThreads', default=1, help="Optionally set maximum number of available threads. Default is 1.")

parser.add_argument("--directed", dest='directed', action='store_true', help="Optionally specify directedness of graph. Default is directed.")
parser.add_argument("--undirected", dest='directed', action='store_false', help="Optionally specify directedness of graph. Default is directed.")
parser.add_argument("--seperator", default="\t", help="Optionally pass seperator between source and destination vertex, default is '\t' .")

parser.add_argument("--firstnode", type=int, default=0, help="Optionally pass index of first node of the graph, default firstnode is 0.")
parser.add_argument("--normalized", dest='normalized', action='store_true', help="Optionally obtain normalized closeness scores.")

parser.set_defaults(directed=True, normalized=False)

args = parser.parse_args()

nk.setNumberOfThreads(args.numThreads)

load_start = timeit.default_timer()

try:
    G = nk.graphio.EdgeListReader(separator=args.seperator, firstNode=args.firstnode, directed=args.directed).read(args.input)
except:
    print("Error while reading graph: ", sys.exc_info()[0], file=sys.stderr)
    raise

calculate_start = timeit.default_timer()

# As we cannot assume connected graphs and the standard definition of closeness is not defined
# on disconnected graphs, we always use the generalized definition.

C = nk.centrality.Closeness(G, args.normalized, nk.centrality.ClosenessVariant.Generalized)
C.run()

dump_start = timeit.default_timer()

with open(args.output, "w") as output_file:
    print_results(C.scores(), output_file, False)

dump_end = timeit.default_timer()

# write benchmarking times to stdout, rest to stderr, so we can separate
print(f"Wrote results to {args.output}.\n", file=sys.stderr)
print("loading time\tcalculating time\tdumping time", file=sys.stderr)
print(f"{calculate_start - load_start}\t{dump_start - calculate_start}\t{dump_end - dump_start}", file=sys.stdout)
