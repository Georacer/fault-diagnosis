function [ A, varIds, eqIndices, varIndices ] = getSubmodel( gi, varargin )
%GETSUBMODEL Return the unknown submodel given an equation subset
%   Detailed explanation goes here

% TODO: This should use V2E and not E2V. But E2V is used to help matching.
% An option should be made available.

p = inputParser;
expectedDirection = {'V2E','E2V'};

p.addRequired('gh',@(x) true);
p.addRequired('eqIds',@isnumeric);
p.addOptional('varIds', gi.graph.variableIdArray,@isnumeric);
p.addParameter('direction','V2E',@(x) any(validatestring(x,expectedDirection)));

p.parse(gi, varargin{:});
opts = p.Results;

eqIds = opts.eqIds;
varIds = opts.varIds;
% if nargin<3
%     varIds = gh.variableIdArray;
% end

eqIndices = gi.getIndexById(eqIds);
varIndices = gi.getIndexById(varIds);

% Get submatrix
if strcmp(opts.direction,'V2E');
    A = gi.adjacency.V2E';
else
    A = gi.adjacency.E2V;
end
A = A(eqIndices,varIndices);

% Keep only related variables
cols2Keep = logical(sum(A,1));
A = A(:,cols2Keep);
varIndices = varIndices(cols2Keep);

% Keep only unknown variables
cols2Keep = zeros(size(A,2));

k=1;
for i = varIndices
    if ~gi.graph.variables(i).isKnown
        cols2Keep(k) = 1;
    end  
    k = k+1;
end
cols2Keep = logical(cols2Keep);
A = A(:,cols2Keep);
varIndices = varIndices(cols2Keep);

varIds = gi.reg.variableIdArray(varIndices);

end

