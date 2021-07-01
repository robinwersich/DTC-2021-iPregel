import networkit as nk
import sys
import argparse

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
parser.add_argument("--normalized", dest='normalized', action='store_true', help="Optionally obtain normalized betweenness scores.")

parser.set_defaults(directed=True, normalized=False)

args = parser.parse_args()

nk.setNumberOfThreads(args.numThreads)

try:
    G = nk.graphio.EdgeListReader(separator=args.seperator, firstNode=args.firstnode, directed=args.directed).read(args.input)
except:
    print("Error while reading graph: ", sys.exc_info()[0])
    raise

print("Successfully read Graph. \n")
print(nk.overview(G))

B = nk.centrality.Betweenness(G, normalized=args.normalized)
B.run()

with open(args.output, "w") as output_file:
    print_results(B.scores(), output_file, False)

print("Wrote results to {}.\n".format(args.output))


