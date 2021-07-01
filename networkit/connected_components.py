import networkit as nk
import sys
import argparse

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

try:
    G = nk.graphio.EdgeListReader(separator=args.seperator, firstNode=args.firstnode, directed=args.directed).read(args.input)
except:
    print("Error while reading graph: ", sys.exc_info()[0])
    raise

print("Successfully read Graph. \n")
print(nk.overview(G))

# Depending on directedness of graph we either calculate connected components (undirected graphs)
# or strongly connected components (directed graphs)
if args.directed:
    S = nk.components.StronglyConnectedComponents(G)
else:
    S = nk.components.ConnectedComponents(G)

S.run()

component_type = "Strongly Connected Components" if args.directed else "Connected Components"
print("Found {} {} \n".format(S.numberOfComponents(), component_type))

nk.gephi.exportNodeValues(S.getPartition(), args.output, component_type)
print("Wrote results to {}.\n".format(args.output))


