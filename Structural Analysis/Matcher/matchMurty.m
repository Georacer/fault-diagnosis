function [ M ] = matchMurty( matcher, varargin )
%MATCHMURTY Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

p.addRequired('matcher', @(x) true);
p.addRequired('numMatchings',@(x) true);
p.addParameter('maxSearchTime', inf, @isnumeric);
p.parse(matcher, varargin{:});
opts = p.Results;

numMatchings = opts.numMatchings;
maxSearchTime = opts.maxSearchTime;
if ~isinf(maxSearchTime)
    warning('maxSearchTime argument not supported for matchMurty. Try contraining numMatchings parameter');
end

debug = false;
% debug = true;

gi = matcher.gi;

V2E = gi.adjacency.V2E; % Use the V2E part to allow non-invertibilitities. This is filled with 1s and 0s
E2V = gi.adjacency.E2V'; % Use E2V to take into account the edge costs.
E2V(E2V==0) = 1; % Override non-invertibilities; they should be enforced by V2E
A = E2V.*V2E;
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

% Set maximum amount of matchings examined
if nargin<2
    nnzEls = nnz(A);
    numMatchings = factorial(nnzEls);
end
if (numMatchings == 0)
    nnzEls = nnz(A);
    numMatchings = factorial(nnzEls);
end

A(A==0) = inf;

matching = murty(A, numMatchings); % matching returned in the form variables->equations (because V2E is provided)
varIdsArray = zeros(size(matching));
for i = 1:size(varIdsArray,1)
    varIdsArray(i,:) = varIds;
end

M = arrayfun(@(x,y) gi.getEdgeIdByVertices(x,y), varIdsArray, equIds(matching));

end
