import networkit as nk
import sys
import argparse
import timeit

parser = argparse.ArgumentParser()

parser.add_argument("input", help="(Relative Path to) graph in edgelist format (e.g. SNAP) to run algorithm on. Default seperator is tab.")
parser.add_argument("output", help="Relative path to name of outputfile.")

parser.add_argument("--numThreads", type=int, dest='numThreads', default=1, help="Optionally set maximum number of available threads. Default is 1.")

parser.add_argument("--directed", dest='directed', action='store_true', help="Optionally specify directedness of graph. Default is directed.")
parser.add_argument("--undirected", dest='directed', action='store_false', help="Optionally specify directedness of graph. Default is directed.")
parser.add_argument("--seperator", default="\t", help="Optionally pass seperator between source and destination vertex, default is '\t' .")

parser.add_argument("--firstnode", type=int, default=0, help="Optionally pass index of first node of the graph, default firstnode is 0.")

parser.set_defaults(directed=True)

args = parser.parse_args()

nk.setNumberOfThreads(args.numThreads)

load_start = timeit.default_timer()

try:
    G = nk.graphio.EdgeListReader(separator=args.seperator, firstNode=args.firstnode, directed=args.directed).read(args.input)
except:
    print("Error while reading graph: ", sys.exc_info()[0], file=sys.stderr)
    raise

calculate_start = timeit.default_timer()

# Depending on directedness of graph we either calculate connected components (undirected graphs)
# or strongly connected components (directed graphs)
if args.directed:
    S = nk.components.StronglyConnectedComponents(G)
else:
    S = nk.components.ConnectedComponents(G)

S.run()

dump_start = timeit.default_timer()

with open(args.output, "w") as output_file:
    for vertex_id in range(G.numberOfNodes()):
        print(f"{vertex_id}\t{S.componentOfNode(vertex_id)}", file=output_file)

dump_end = timeit.default_timer()

# write benchmarking times to stdout, rest to stderr, so we can separate
print(f"Wrote results to {args.output}.\n", file=sys.stderr)
print("loading time\tcalculating time\tdumping time", file=sys.stderr)
print(f"{calculate_start - load_start}\t{dump_start - calculate_start}\t{dump_end - dump_start}", file=sys.stdout)
