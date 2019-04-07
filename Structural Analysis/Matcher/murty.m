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

debug = false;
% debug = true;

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
        if debug; fprintf('Possible matchings depleted'); end
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
        if debug; fprintf('inf cost met, returning'); end
        return;
    end
end


end

function [ partitions, costs ] = murtyPartition( C, node )
%% MURTYPARTITION The node partition procedure for Murty's algorithm
% as presented on:
% Murty, K. G. (1968).
% Letter to the Editor—An Algorithm for Ranking all the Assignments in Order of Increasing Cost.
% Operations Research, 16(3), 682–687.
% doi:10.1287/opre.16.3.682

% Implemented by George Zogopoulos Papaliakos, Jan 2016
% This function is split across 2 files:
% 1. murty.m
% 2. murtyPartition.m

% INPUTS:  C - a square cost matrix
%          node - the node structure to be partitioned
% OUTPUTS: partitions - a [1,k] node array, containing the partitions
%          costs - a [1,k] array, with the partition minimum costs 

%% Inputs checks

if nargin<2
    error('Required inputs: C, node');
end

if size(C,1)~=size(C,2)
    error('Input cost must be rectangular');
end

%% Data initialization and validation

n = size(C,2);

contain = node.contain;
if isempty(contain)
    contain = zeros(0,2);
end
r = size(contain,1);
exclude = node.exclude;
assignment = node.assignment;

pivot = setdiff(assignment,contain,'rows');
k = size(pivot,1);

% If the predefined matching is complete on the partition, return no
% children
if r==n
    partitions = [];
    costs = [];
    return
end

if (r+k)~=n
    error('Size mismatch');
end

%% Main body

counter = 1; % How many new nodes will be produced

for i=1:(k-1)

    % Create the new node constraints
    newnode = node;
    newnode.exclude = [exclude ; pivot(i,:)];
    newnode.contain = [contain ; pivot(1:(i-1),:)];
    
    remainingRows = setdiff([1:n],newnode.contain(:,1));
    remainingCols = setdiff([1:n],newnode.contain(:,2));
    
    % Create the corresponding sub-matrix
    D = C;
    row = newnode.exclude(:,1);
    col = newnode.exclude(:,2);
    indices = sub2ind(size(C), row, col);
    D(indices) = inf; % Apply the barred cosntraints    
    D = D(remainingRows,remainingCols); % and remove the compulsory assignments
    
    newAss = munkres(D); % Calculate cheapest matching
    
    j = find(newAss==0); % TODO: Investigate if the case where the whole first row is inf is a valid outcome
    if j
%         warning('First row all inf');
        continue
    end
    
    % Store the new assignment
    newnode.assignment = [newnode.contain; [remainingRows' remainingCols(newAss(1,:))']];
    newnode.assignment = sortrows(newnode.assignment);
    % Store the new cost
    newnode.cost = sum(diag(C(:,newnode.assignment(:,2))));
    
    % Add the new partition to the output buffer
    costs(counter) = newnode.cost;
    partitions(counter) = newnode;
    counter = counter+1;
    
end

if ~exist('partitions')
    partitions = [];
end
if ~exist('costs')
    costs = [];
end


end