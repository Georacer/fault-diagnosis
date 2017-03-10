function [  ] = matchingPlot( Graph, residuals, rankVar, rankCon )
%MATCHINGPLOT DEPRECATED - Plot the matching of Graph
%   Variables are positioned in the units of x-axis
%   Constraints are positioned in the half-space between
%   A unit and the half-space on its right represent one rank

numVars = size(Graph.adjacency,2);
numCons = size(Graph.adjacency,1);
adjacency = Graph.adjacency;

for i=find(rankVar==inf) % Erase unmatched variables from adjacency matrix
    adjacency(:,i)=zeros(size(adjacency,1),1);
end
for i=find(rankCon==inf) % Erase unmatched constraints from the adjacency matrix
    adjacency(i,:)=zeros(1,size(adjacency,2));
end

% Construct the extended adjacency matrix, which is required by the gplot
% function
extendedAdj = [eye(numVars) adjacency' zeros(numVars,numCons);...
    adjacency eye(numCons) diag(residuals);...
    zeros(numCons,numVars) diag(residuals) eye(numCons)];
% Initialize the set containing the coordinates of each node
coords = ones(numVars+numCons+length(residuals),2);

figure();
hold on;

for i=0:max(rankVar(isfinite(rankVar)))+1 % for the matched variable ranks
    vars2plot = find(rankVar==i); % find the a variables of the current rank
    for j=1:length(vars2plot)
        coords(vars2plot(j),1)=i;
        coords(vars2plot(j),2)=j;
        text(i+0.05,j+0.05,Graph.vars{vars2plot(j)},'FontSize',14);
    end
    cons2plot = find(rankCon==i);
    for j=1:length(cons2plot)
        coords(cons2plot(j)+numVars,1)=i+0.5;
        coords(cons2plot(j)+numVars,2)=j+0.6;
        text(i+0.55,j+0.65,Graph.constraints{cons2plot(j)},'FontSize',14);
    end
    res2plot = find((rankCon==(i-1)).*residuals);
    for j=1:length(res2plot)
        coords(res2plot(j)+numVars+numCons,1) = i;
        coords(res2plot(j)+numVars+numCons,2) = j+length(vars2plot);
        text(i+0.05,j+length(vars2plot)+0.05,sprintf('ZERO-%s',Graph.constraints{res2plot(j)}),'FontSize',14);
    end
end

gplot(extendedAdj,coords,'-o');
grid on
set(gca,'Xtick',[0:1:(max(rankVar(isfinite(rankVar)))+1)]);
set(gca,'Ytick',[]);


end

