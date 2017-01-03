function [ M ] = matchMurty( gh, eqIds, varIds )
%MATCHMURTY Summary of this function goes here
%   Detailed explanation goes here

debug = false;

if nargin==1
    eqIds = gh.equationIdArray;
end

if nargin<=2
    [A, varIds, eqIndices, varIndices] = gh.getSubmodel(eqIds,'direction','V2E');
end

if nargin==3
    [A, varIds, eqIndices, varIndices] = gh.getSubmodel(eqIds,varIds,'direction','V2E');
end

if debug
    fprintf('*** Murty: Examining equations ');
    disp(gh.equationAliasArray(eqIndices));
    fprintf(' and variables ');
    disp(gh.variableAliasArray(varIndices));
end

% Get variable IDs
varIds = gh.variableIdArray(varIndices);
% Get equation IDs
equIds = gh.equationIdArray(eqIndices);

% Test if A is square
if size(A,1)~=size(A,2)
    error('Given submodel is not just-constrained');
end

% Set impossible matchings
nnzEls = nnz(A);
A(A==0) = inf;

matching = murty(A,factorial(nnzEls));
equIdsArray = zeros(size(matching));
for i = 1:size(equIdsArray,1)
    equIdsArray(i,:) = equIds;
end

M = arrayfun(@(x,y) gh.getEdgeIdByVertices(x,y), equIdsArray, varIds(matching));

end
