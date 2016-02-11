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

