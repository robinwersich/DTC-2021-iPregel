import sys
import pandas as pd
import os


if len(sys.argv) <= 1 or not os.path.exists(sys.argv[1]):
    print(f"usage: {sys.argv[0]} <relative_path_to_graph>")
    sys.exit()

input_file_path = sys.argv[1]
output_file_path = os.path.dirname(input_file_path) + '/processed_' + os.path.basename(input_file_path)

df = pd.read_csv(input_file_path, delim_whitespace=True)

# drop unneccesary timestamp and interaction type information
df.drop(df.columns[2:4], axis=1, inplace=True)

# drop duplicate interactions where e.g. userA retweeted and mentioned userB
df.drop_duplicates(keep='first', inplace=True)

# delete self-interactions, e.g. userA retweeted userA
print("Number of self-interactions: {} \n".format(len(df[df.iloc[:, 0] == df.iloc[:, 1]])))
df = df[df.iloc[:, 0] != df.iloc[:, 1]]

df.to_csv(output_file_path, header=None, index=None, sep=' ', mode='w')

# data sanity check => get max and min Node ID value

min_node_id = min(df.iloc[:,0].min(), df.iloc[:,1].min())
max_node_id = max(df.iloc[:,0].max(), df.iloc[:,1].max())

print("Min NodeID: {}, Max NodeID: {} \n".format(min_node_id, max_node_id))

# print result for debug purposes
print("Resulting dataframe: \n")
print(df)