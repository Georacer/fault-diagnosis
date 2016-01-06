function [ id ] = getEdgeIdByVertices( gh, equId, varId )
%GETEDGEIDBYVERTICES Summary of this function goes here
%   Detailed explanation goes here

id = [];

for i=1:gh.numEdges
    if (gh.edges(i).equId==equId) && (gh.edges(i).varId==varId)
        id = gh.edges(i).id;
        return
    end
end

end

