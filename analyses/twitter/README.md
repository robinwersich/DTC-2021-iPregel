# Higgs-Twitter Graph: Node Importance vs. Follower Count

## Analysed Graph
The [Higgs Twitter Data Set](https://snap.stanford.edu/data/higgs-twitter.html) is a network of user activities (Retweeting, Replying, Mentioning) centered around the discovery of a new particle "with the elusive Higgs boson on 4th July 2012". 

We choose to include all possible user interactions into our analyses and treat them equally. If a user i retweeted a post from user j, replied to a post of user j or mentioned user j, the graph contains a directed edge from i to j. If a user outside of the dataset interacted with a user within the data set, the graph does not conatin any information about this.

The graph contains collected messages posted in Twitter about this discovery between the 1st and 7th of July 2012. 

Users are identified by anonimized User IDs.

The Higgs Twitter Dataset additionally contains information about the social structure (follower relationships among users involved in the recorded activites).



## Goal

We will use the provided interaction network containing all types of interactions (Retweeting, Replying, Mentioning) to compute our selected node importance algorithms upon.

As a classical node importance score to compare them against we will retrieve the follower count of each involved user. We will retrieve this measure by computing the degree centrality of each user node in the follower relationship graph.

## Preprocessing

### Interaction Network
- We downloaded the [higgs-activity_time](https://snap.stanford.edu/data/higgs-activity_time.txt.gz) data set which provides us with the following format: 

```
userA userB timestamp interaction
```
- As we are only interested in the occurrence of an interaction and the direction of the interaction and not interested in the type of the interaction, we drop the timestamp and interaction type information.

- As we are only interested in the occurrence of one interaction, we reduce multiple interactions (e.g. retweeting and mentioning the same user) to just one interaction edge. This reduces the edge count by 96522.

- As we want the node importance of a node to only be impacted by the interaction that other nodes have with we also erased self references. This reduces the edge count by 5353.

- We then use the `Snap2iPregel` converter to convert the graph into the needed format.



### Follower Count
- We downloaded the [social_network.edgelist](https://snap.stanford.edu/data/higgs-social_network.edgelist.gz) data set which provides us with the following format where userA follows userB: 

```
userA userB 
```

- We use [networkit](https://networkit.github.io) to compute the InDegreeCentrality for each node which in our setup equals the number of followers a node has. 



## Inconsistencies in SNAP provided node / edge counts and our counts

### User interaction network
- According to the official [SNAP Page for the Dataset](https://snap.stanford.edu/data/higgs-twitter.html) there are 456 626 users involved in the interactions / nodes in the graph. Our converted interaction graph however only has 456 623 nodes. When analyzing our interaction graph we found that node 1 and nodes 456 623, 456 624, 456 624, 456 626 seem to not have actually interacted with other users. This also doesn't up, because we would in this case expect 456 626 - 5 = 456 621 participating nodes.

- Additionally, when suming up the interactions in networks split up in regards to interaction type, so the Retweeting, Repling and Mentioning Networks, we don't arrive at the edge count of our interaction network. 
328132 (Retweet) + 32523 (Reply) + 150818 (Mention) = 511 473 ≠ 563068 edges in the interaction network.



