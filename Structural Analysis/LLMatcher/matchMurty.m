function [ M ] = matchMurty( matcher, numMatchings )
%MATCHMURTY Summary of this function goes here
%   Detailed explanation goes here

debug = false;
% debug = true;

gi = matcher.gi;

% if nargin==1
%     eqIds = gi.equationIdArray;
% end
% 
% if nargin<=2
%     [A, varIds, eqIndices, varIndices] = gi.getSubmodel(eqIds,'direction','V2E');
% end
% 
% if nargin==3
%     [A, varIds, eqIndices, varIndices] = gi.getSubmodel(eqIds,varIds,'direction','V2E');
% end

V2E = gi.adjacency.V2E; % Use the V2E part to allow non-invertibilitities. This is filled with 1s and 0s
A = gi.adjacency.E2V'.*V2E; % Multiply with E2V to take into account the edge costs.
equIds = gi.reg.equIdArray;
varIds = gi.reg.varIdArray;


if debug
    fprintf('*** Murty: Examining equations ');
    disp(gi.getAliasById(equIds));
    fprintf(' and variables ');
    disp(gi.getAliasById(varIds));
end

% Test if A is square
if size(A,1)~=size(A,2)
    error('Given submodel is not just-constrained (this needs more work, to actually verify that this is just-constrained)');
end
% Redundant test
if (length(equIds)~=length(varIds))
    error('Given submodel is not just-constrained (2)');
end

% Set impossible matchings
if nargin<2
    nnzEls = nnz(A);
    numMatchings = factorial(nnzEls);
end

A(A==0) = inf;

matching = murty(A,numMatchings); % matching returned in the form variables->equations (because V2E is provided)
varIdsArray = zeros(size(matching));
for i = 1:size(varIdsArray,1)
    varIdsArray(i,:) = varIds;
end

M = arrayfun(@(x,y) gi.getEdgeIdByVertices(x,y), varIdsArray, equIds(matching));

end
