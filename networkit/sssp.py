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
parser.add_argument("--startnode", type=int, default=0, help="Optionally pass index of startnode for sssp, default startnode is 0.")

parser.set_defaults(directed=True)

args = parser.parse_args()

try:
    G = nk.graphio.EdgeListReader(separator=args.seperator, firstNode=args.firstnode, directed=args.directed).read(args.input)
except:
    print("Error while reading graph: ", sys.exc_info()[0])
    raise

print("Successfully read Graph. \n")
print(nk.overview(G))

S = nk.distance.Dijkstra(G, args.startnode)
S.run()

nk.gephi.exportNodeValues(S.getDistances(), args.output, "Distance to node " + str(args.startnode))
print("Wrote results to {}.\n".format(args.output))


