function [ A, varIds, eqIndices, varIndices ] = getSubmodel( gh, eqIds, varIds )
%GETSUBMODEL Return the unknown submodel given an equation subset
%   Detailed explanation goes here

if nargin<3
    varIds = gh.variableIdArray;
end

eqIndices = gh.getIndexById(eqIds);
varIndices = gh.getIndexById(varIds);

% Get submatrix
A = gh.adjacency.E2V;
A = A(eqIndices,varIndices);

% Keep only related variables
cols2Keep = logical(sum(A,1));
A = A(:,cols2Keep);
varIndices = varIndices(cols2Keep);

% Keep only unknown variables
cols2Keep = zeros(size(A,2));

k=1;
for i = varIndices
    if ~gh.variables(i).isKnown
        cols2Keep(k) = 1;
    end  
    k = k+1;
end
cols2Keep = logical(cols2Keep);
A = A(:,cols2Keep);
varIndices = varIndices(cols2Keep);

varIds = gh.variableIdArray(varIndices);

end

