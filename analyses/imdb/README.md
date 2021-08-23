# IMDB Actors Network: Node Importance vs. (Perceived) Fame of Actors

## Analysed Network
The [IMDB Actors Network](http://law.di.unimi.it/webdata/hollywood-2011/) is a network of actor collaboration based on the imdb movie database. "Vertices are actors, and two actors are joined by an edge whenever they appeared in a movie together."

This is the only undirected network in our network selection.

## Goal

We want to compare the results of our applied node importance algorithms (except PageRank, because on undirected networks it doesn't yield interpretable results) to our perceived fame of the involved actors. As analysis helpers we want to, for instance, refer to an all time list of Academy Award nominations (https://en.wikipedia.org/wiki/List_of_actors_with_Academy_Award_nominations).

## Preprocessing

### Actor network

We downloaded the network (`.graph` and `.properties` files) from the [Laboratory for Web Algorithmics](http://law.di.unimi.it/webdata/hollywood-2011/). The network is stored in the [WebGraph](https://webgraph.di.unimi.it) format, a binary format used to store huge graphs (e.g. webgraphs) with compression.
To convert the network from `WebGraph` to `SNAP` format we used an adapted version of this [WebGraphDecoder](https://gist.github.com/iwiwi/5351417) found on GitHub.

### Analysis data

- We've prepared the id look-up file to be able to match actor ids of our graph with names and the Academy Award Nominee List from Wikipedia which can be found in the results folder.
