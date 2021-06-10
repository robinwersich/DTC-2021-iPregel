import networkit as nk
import pandas as pd

input_file = './data/higgs-social_network.edgelist'
output_file = './data/follower_count_higgs_network.txt'
sorted_output_file = './data/sorted_follower_count_higgs_network.txt'

G = nk.readGraph(input_file, nk.Format.EdgeList, separator=" ", firstNode=1, directed=True)

print(nk.overview(G), '\n')

D = nk.centrality.DegreeCentrality(G, outDeg=False, ignoreSelfLoops=True)
D.run()
follower_counts = D.scores()

df = pd.DataFrame(follower_counts, columns=['Follower Count'])

# NodeIDs are 1-indexed
df.index += 1

df.to_csv(output_file, header=None, sep=' ', mode='w', float_format='%.f')
print('Wrote follower counts to {} \n'.format(output_file))

sorted_df = df.sort_values(by='Follower Count', ascending=False)

sorted_df.to_csv(sorted_output_file, header=None, sep=' ', mode='w', float_format='%.f')
print('Wrote sorted follower counts to {} \n'.format(sorted_output_file))


