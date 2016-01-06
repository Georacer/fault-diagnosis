function [ resp ] = isMatchable( gh, id )
%ISMATCHABLE Decide if an edge can be matched
%   Detailed explanation goes here

% TODO: take into account causality input

if ~gh.isEdge(id)
    error('Only edges can pass this test');
end

resp = true;

edgeIndex = gh.getIndexById(id);

if gh.edges(edgeIndex).isMatched
    % No operation
end
if gh.edges(edgeIndex).isDerivative
    % No operation
end
if gh.edges(edgeIndex).isIntegral
    % No operation
end
if gh.edges(edgeIndex).isNonSolvable
    resp = false;
end

varIndex = gh.getIndexById(gh.edges(edgeIndex).varId);

if gh.variables(varIndex).isKnown
    % No operation
end
if gh.variables(varIndex).isMeasured
    resp = false;
end
if gh.variables(varIndex).isInput
    resp = false;
end
if gh.variables(varIndex).isOutput
    % No operation
end

end

