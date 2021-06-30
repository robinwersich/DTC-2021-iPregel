import sys
import os
import networkit as nk
import pandas as pd

if len(sys.argv) <= 1 or not os.path.exists(sys.argv[1]):
    print(f"usage: {sys.argv[0]} <relative_path_to_social_network_edgelist>")
    sys.exit()

input_file_path = sys.argv[1]
output_file_path = os.path.dirname(input_file_path) + '/follower_count_' + os.path.splitext(os.path.basename(input_file_path))[0] + '.txt'
sorted_output_file_path = os.path.dirname(input_file_path) + '/sorted_follower_count_' + os.path.splitext(os.path.basename(input_file_path))[0] + '.txt'

G = nk.readGraph(input_file_path, nk.Format.EdgeList, separator=" ", firstNode=1, directed=True)

print(nk.overview(G), '\n')

D = nk.centrality.DegreeCentrality(G, outDeg=False, ignoreSelfLoops=True)
D.run()
follower_counts = D.scores()

df = pd.DataFrame(follower_counts, columns=['Follower Count'])

# NodeIDs are 1-indexed
df.index += 1

df.to_csv(output_file_path, header=None, sep=' ', mode='w', float_format='%.f')
print('Wrote follower counts to {} \n'.format(output_file_path))

sorted_df = df.sort_values(by='Follower Count', ascending=False)

sorted_df.to_csv(sorted_output_file_path, header=None, sep=' ', mode='w', float_format='%.f')
print('Wrote sorted follower counts to {} \n'.format(sorted_output_file_path))


