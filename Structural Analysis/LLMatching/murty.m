function [assignments, costs] = murty(C,k)
%% MURTY Murty's algorithm, for finding the k best matchings
% As presented on:
% Murty, K. G. (1968).
% Letter to the Editor—An Algorithm for Ranking all the Assignments in Order of Increasing Cost.
% Operations Research, 16(3), 682–687.
% doi:10.1287/opre.16.3.682

% Implemented by George Zogopoulos Papaliakos, Jan 2016
% This function is split across 2 files:
% 1. murty.m
% 2. murtyPartition.m

% INPUTS:  C - a square cost matrix
%          k - the number of matchings to be returned (default 1)  
% OUTPUTS: assignments - a [k,n] array, with one matching on each row
%          costs - a [1,k] array, with the assignment costs 

%% Input checks
if nargin<2
    k=1;
end

if size(C,1)~=size(C,2)
    error('Cost matrix must be square');
end

% Example matrix from original paper:
% C = [...
%     7 51 52 87 38 60 74 66 0 20;...
%     50 12 0 64 8 53 0 46 76 42;...
%     27 77 0 18 22 48 44 13 0 57;...
%     62 0 3 8 5 6 14 0 26 39;...
%     0 97 0 5 13 0 41 31 62 48;...
%     79 68 0 0 15 12 17 47 35 43;...
%     76 99 48 27 34 0 0 0 28 0;...
%     0 20 9 27 46 15 84 19 3 24;...
%     56 10 45 39 0 93 67 79 19 38;...
%     27 0 39 53 46 24 69 46 23 1;...
%     ];

% Example matrix #2
% C = [...
%     1 1 inf;...
%     1 1 1;...
%     inf 1 1;...
%     ];

%% Data initialization

n = size(C,1);
costs = [];

assignment = zeros(n,2);
assignment(:,1) = (1:n)';
assignment(:,2) = munkres(C)'; % calculate initial best matching, using the Hungarian algorithm

% Prepare the first node structure
node.contain = [];
node.exclude = [];
node.assignment = assignment;
node.cost = sum(diag(C(:,node.assignment(:,2))));

% Add matching and cost to the results
assignments = assignment(:,2)';
costs = node.cost;

nodeArray = [node];
costArray = [node.cost];
index = 1;

%% Loop over the required matchings

% For each next matching
for i=2:k
    % Partition the cheapest node
    [newnodes, newcosts] = murtyPartition(C,nodeArray(index));
    % Add its components to the node list
    nodeArray = [nodeArray newnodes];
    costArray = [costArray newcosts];
    % Delete the initial cheapest node
    nodeArray(index) = [];
    costArray(index) = [];
    % Check if there are any nodes left
    if isempty(costArray)
        warning('Possible matchings depleted');
        return;
    end
    % Find the new cheapest node
    [~,index] = min(costArray);
    % Add its matching and cost to the results
    assignments(end+1,:) = nodeArray(index).assignment(:,2)';
    costs(end+1) = costArray(index);
    % If a matching with inf cost is met, then it is invalid and all next
    % matchings are invalid too
    if costs(end)==inf
        warning('inf cost met, returning');
        return;
    end
end


end