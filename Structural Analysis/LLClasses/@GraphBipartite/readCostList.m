function [ resp ] = readCostList( gh, list )
%READCOSTLIST Summary of this function goes here
%   Detailed explanation goes here

if size(list,1)~=gh.numEdges
    resp = false;
    error('List length is not equal to number of graph edges');
elseif size(list,2)~=5
    resp = false;
    error('List is expected to have 5 columns: equId, varId, equAlias, varAlias, weight');
else
    for i=1:size(list,1)
        equId = list{i,1};
        varId = list{i,2};
        weight = list{i,5};
        id = gh.getEdgeIdByVertices(equId, varId);
        gh.setEdgeWeight(id, weight);        
    end
end

end

