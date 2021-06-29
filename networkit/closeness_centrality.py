import networkit as nk
import sys
import argparse

parser = argparse.ArgumentParser()

parser.add_argument("input", help="(Relative Path to) graph in edgelist format with space seperator (e.g. SNAP) to run algorithm on.")
parser.add_argument("output", help="Relative path to name of outputfile.")

parser.add_argument("--directed", dest='directed', action='store_true', help="Optionally specify directedness of graph. Default is directed.")
parser.add_argument("--undirected", dest='directed', action='store_false', help="Optionally specify directedness of graph. Default is directed.")
parser.add_argument("--seperator", default="\t", help="Optionally pass seperator between source and destination vertex, default is '\t' .")

parser.add_argument("--firstnode", type=int, default=0, help="Optionally pass index of first node of the graph, default firstnode is 0.")
parser.add_argument("--normalized", dest='normalized', action='store_true', help="Optionally obtain normalized closeness scores.")

parser.set_defaults(directed=True, normalized=False)


args = parser.parse_args()

try:
    G = nk.graphio.EdgeListReader(separator=args.seperator, firstNode=args.firstnode, directed=args.directed).read(args.input)
except:
    print("Error while reading graph: ", sys.exc_info()[0])
    raise

print("Successfully read Graph. \n")
print(nk.overview(G))

# As we cannot assume connected graphs and the standard definition of closeness is not defined
# on disconnected graphs, we always use the generalized definition.

C = nk.centrality.Closeness(G, args.normalized, nk.centrality.ClosenessVariant.Generalized)
C.run()

nk.gephi.exportNodeValues(C.scores(), args.output, "Closeness Centrality")
print("Wrote results to {}.\n".format(args.output))


