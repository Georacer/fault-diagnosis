clear;
modelFile;
Graph = modelParser(constraints);
matching = matchingRanking(Graph);
[g, coords] = matchingPlot2(Graph, matching);
g.setNodePositions(coords);