function [ respAdded, id ] = addEdge( gh, id,equId,varId,edgeProps )
%ADDEDGE Summary of gh function goes here
%   Detailed explanation goes here

% debug = true;
debug = false;

if isempty(id)
    error('No edge ID provided');
end

if debug; fprintf('addEdge: Creating new Edge object\n'); end
tempEdge = Edge(id,equId,varId); % Create a new edge object
tempEdge.isMatched = edgeProps.isMatched;
tempEdge.isDerivative = edgeProps.isDerivative;
tempEdge.isIntegral = edgeProps.isIntegral;
tempEdge.isNonSolvable = edgeProps.isNonSolvable;

if debug; fprintf('addEdge: Assigning the edge object to the graph\n'); end
gh.edges(end+1) = tempEdge;

respAdded = true;
if debug; fprintf('addEdge: Created new edge from (%d,%d) with ID %d\n',equId,varId,id); end

end