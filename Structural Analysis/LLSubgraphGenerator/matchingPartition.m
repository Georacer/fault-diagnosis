function [ GraphNew, partition ] = matchingPartition( Graph, matching )
%MATCHINGPARTITION Partition a Graph based on system constraints
%   Partitions a Graph onto three subsystems and reorders constraints and
%   variables based on whether the subystems are under- just- and over-
%   constrained

residuals = matching.residuals;
edges = matching.edges;
rankVar = matching.rankVar;

adjacency = Graph.adjacency;
vars = Graph.vars;
constraints = Graph.constraints;

numRes = sum(residuals);

% Bring unmatched constraints on top
if (find(residuals))
    [~, index] = sort(residuals,'descend');
    constraints = constraints(index);
    adjacency = adjacency(index,:);
end

% Diagonalize the matching
% Send unmatched variables to the right
% Send input variables to the right
constraints((1:length(edges))+numRes) = constraints(edges(:,2));
adjacency((1:length(edges))+numRes,:) = adjacency(edges(:,2),:);
% vars(1:length(edges)) = vars(edges(:,1));
vars = [vars(edges(:,1)) vars(find(rankVar==inf)) vars(find(rankVar==0))];
% adjacency(:,1:length(edges)) = adjacency(:,edges(:,1));
adjacency = [adjacency(:,edges(:,1)) adjacency(:,find(rankVar==inf)) adjacency(:,find(rankVar==0))];

partition = [];
GraphNew.adjacency = adjacency;
GraphNew.vars = vars;
GraphNew.constraints = constraints;

end

