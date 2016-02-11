function [ resp ] = setEdgeWeight( gh, id, weight )
%SETEDGEWEIGHT Summary of this function goes here
%   Detailed explanation goes here

if size(id)~=size(weight)
    error('id and weight arrays size mismatch');
end

for i=1:length(id)
    
    index = gh.getIndexById(id(i));
    
    if gh.isEdge(id(i))
        gh.edges(index).weight = weight(i);
    else
        error('Object with ID %d is not an edge',id(i));
    end
    
end


end
