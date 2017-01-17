function [ resp ] = setEdgeWeight( gh, indices, weights )
%SETEDGEWEIGHT Summary of this function goes here
%   Detailed explanation goes here

if size(indicse)~=size(weights)
    error('id and weight arrays size mismatch');
end

for i=1:length(indices)
    
    gh.edges(indices(i)).weight = weights(i);
    
end


end
