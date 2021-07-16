package com.dtc;

/*
 * Credit goes to
 * https://gist.github.com/iwiwi/5351417
 */

import it.unimi.dsi.fastutil.ints.IntArrayFIFOQueue;
import it.unimi.dsi.fastutil.ints.IntArrays;
import it.unimi.dsi.logging.ProgressLogger;
import it.unimi.dsi.webgraph.GraphClassParser;
import it.unimi.dsi.webgraph.ImmutableGraph;
import it.unimi.dsi.webgraph.LazyIntIterator;

import java.io.*;
import java.util.*;

public class WebGraphDecoder {
  static public void main(String arg[]) throws Exception {
    ImmutableGraph graph = ImmutableGraph.load(arg[0]);
    BufferedWriter bw = new BufferedWriter(new FileWriter(arg[1]));

    int num_v = graph.numNodes();
    System.out.printf("Vertices: %d\n", num_v);
    System.out.printf("Edges: %d\n", graph.numArcs());

    int num_e = 0;
    for (int v = 0; v < num_v; ++v) {
      LazyIntIterator successors = graph.successors(v);
      for (int i = 0; i < graph.outdegree(v); ++i) {
        int w = successors.nextInt();
        bw.write(Integer.toString(v));
        bw.write("\t");
        bw.write(Integer.toString(w));
        bw.write("\n");
        ++num_e;
      }
    }

    bw.flush();
    System.out.printf("Output Edges: %d\n", num_e);
  }
}
