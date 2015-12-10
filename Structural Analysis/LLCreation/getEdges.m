function [ rows, cols ] = getEdges( Graph )
%GETEDGES Summary of this function goes here
%   Detailed explanation goes here
[rows, cols] = find(Graph.adjacency);
[rows, I] = sort(rows);
cols = cols(I);

end

