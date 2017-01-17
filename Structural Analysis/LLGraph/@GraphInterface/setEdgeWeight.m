function [ resp ] = setEdgeWeight( gh, indices, weights )
%SETEDGEWEIGHT Summary of this function goes here
%   Detailed explanation goes here

if size(indicse)~=size(weights)
    error('id and weight arrays size mismatch');
end

for i=1:length(indices)
    
    gh.edges(indices(i)).weight = weights(i);
    if gh.isEdge(id(i))
        gh.edges(index).weight = weight(i);
    else
        error('Object with ID %d is not an edge',id(i));
    end
    
end


end
