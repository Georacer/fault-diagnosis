function [ resp ] = isMatchable( gh, id )
%ISMATCHABLE Decide if an edge can be matched
%   Detailed explanation goes here

if ~gh.isEdge(id)
    error('Only edges can pass this test');
end

resp = true;

edgeIndex = gh.getIndexById(id);

derOK = strcmp(gh.causality,'None') || strcmp(gh.causality,'Mixed') || strcmp(gh.causality,'Differential') || strcmp(gh.causality,'Realistic');
intOK = strcmp(gh.causality,'None') || strcmp(gh.causality,'Mixed') || strcmp(gh.causality,'Integral') || strcmp(gh.causality,'Realistic');
niOK = strcmp(gh.causality,'None');

if gh.edges(edgeIndex).isMatched
   resp = false;
end
if gh.edges(edgeIndex).isDerivative && ~derOK
    resp = false;
end
if gh.edges(edgeIndex).isIntegral && ~intOK
    resp = false;
end
if gh.edges(edgeIndex).isNonSolvable && ~niOK
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

