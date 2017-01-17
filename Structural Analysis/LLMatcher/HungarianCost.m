function [cost] = HungarianCost( A, causality )
% Construct a cost matrix from an adjacency matrix
%
% Build a cost matrix for matching with the Hungarian method. Evaluate the
% adjacency matrix A edges for matching, based on the pricelist provided.
% Matching an edge costs as much as the evaluation of the constraint, using
% the pricelist.

[rows, cols] = size(A);
cost = zeros(size(A));

for i=1:rows
    for j=1:cols
        indices = A(i,:);
        indices(j) = [];
        itemCost = sum(arrayfun(@(vec) pricelist(vec),indices));
        cost(i,j) = itemCost;
    end
end

% Set valid causality to follow during matching. Valid entries are the
% value of variable 'mark' in file 'lineParser.m'. Some valid optiosn are
% 1=char(49), D=char(68)...
% causality = [49];
% causality = [49 68];
index = ismember(A,causality);
cost(~index)=inf;

end