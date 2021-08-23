# Stackoverflow user interactions vs. reputation count

## Analysed Network
The [Stack Overflow temporal network](https://snap.stanford.edu/data/sx-stackoverflow.html) is a network of interactions (answering questions, commenting questions, commenting answers) between users on stackoverflow. We chose to value each interaction equally. The network was generated from a dump which also contained additional information about each user in the form of an XML file.

## Goal

We wanted to compare the results of our applied node importance algorithms with the reputation count (a measure of importance on stackoverflow) of each corresponding user. Sadly, we couldn't retrieve the exact dump used to create the network, so we couldn't retrieve the reputation count either.

## Preprocessing

- We downloaded the [sx-stackoverflow](https://snap.stanford.edu/data/sx-stackoverflow.txt.gz) data set which provides us with the following format: 

```
userA userB timestamp
```
- As we are only interested in the occurrence of an interaction and the direction of the interaction we drop the.

- As we are only interested in the occurrence of one interaction, we reduce multiple interactions to just one interaction edge.

- As we want the node importance of a node to only be impacted by the interaction with other nodes we also erased self references.

- As an important user on stackoverflow who answers and comments many questions has many outgoing but possibly few ingoing edges, the network topology would be reversed in comparison to most social networks (e.g. Twitter) where important users have many ingoing edges. For this reason, we reversed the edges on the stackoverflow network.
