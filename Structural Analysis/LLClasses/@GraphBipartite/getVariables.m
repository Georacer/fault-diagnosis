function [ varIds ] = getVariables( gh, id )
%GETVARIABLES get variables related to an equation
%   Detailed explanation goes here

% debug = true;
debug = false;

if length(id)>1
    error('Cannot support array id');
end

edgeIds = gh.getEdgeIdByProperty('equId',id);
if debug fprintf('getVariables: Related edges: %d\n',length(edgeIds)); end
edgeIndices = gh.getIndexById(edgeIds);
varIds = zeros(size(edgeIndices));

k = 1;
for i=edgeIndices
    varIds(k) = gh.edges(i).varId;
    if debug fprintf('getVariables: Ran loop %d\n',k); end
    k = k + 1;
end

end

