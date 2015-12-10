function [ newGraph ] = applyMatching( Graph, matching )
%APPLYMATCHING Apply a matching edge set on a graph
%   Detailed explanation goes here

newGraph = Graph;

edges = matching.edges;

numVars = size(Graph.vars,2);
numCons = size(Graph.constraints,2);

adjacency = Graph.adjacency;

% Delete all edges defining variables
adjacency((1:numCons) + numVars,:) = zeros(numCons,numVars+numCons);

for i=1:size(edges,1)
    adjacency(numVars + edges(i,2),edges(i,1)) = 1; % enforce matrix directionality
    % !!! Must verify that the vector already exists in the graph
end

newGraph.adjacency = adjacency;

end

