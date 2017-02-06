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

A = gi.adjacency.V2E;
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

matching = murty(A,numMatchings);
equIdsArray = zeros(size(matching));
for i = 1:size(equIdsArray,1)
    equIdsArray(i,:) = equIds;
end

M = arrayfun(@(x,y) gi.getEdgeIdByVertices(x,y), equIdsArray, varIds(matching));

end
