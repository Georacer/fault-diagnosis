function [ w ] = getEdgeWeight( gh, id )
%GETEDGEWEIGHT Summary of this function goes here
%   Detailed explanation goes here

w = zeros(size(id));
edgeIndices = gh.getIndexById(id);

for i=1:length(id)
    if ~gh.isEdge(id(i))
        error('Requested weight of non-edge object');
    end
    w(i) = gh.edges(edgeIndices(i)).weight;
end

end

