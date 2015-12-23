function [ g, coords, GraphM ] = matchingPlot2( Graph, matching )
%MATCHINGPLOT Plot the matching of Graph
%   Variables are positioned in the units of x-axis
%   Constraints are positioned in the half-space between
%   A unit and the half-space on its right represent one rank

gray = [0.3 0.3 0.3];
yellow = [1.0 1.0 0.0];
blue = [0.0 0.2 1.0];
green = [0.2 0.8 0.2];

edges = matching.edges;
residuals = matching.residuals;
rankVar = matching.rankVar;
rankCon = matching.rankCon;

numVars = length(Graph.vars);
numCons = length(Graph.constraints);
numRes = sum(residuals~=0);
indexRes = find(residuals);

adjacency = Graph.adjacency;

for i=find(rankVar==inf) % Erase unmatched variables from adjacency matrix
    adjacency(:,i) = zeros(numVars+numCons,1);
    adjacency(i,:) = zeros(1,numVars+numCons);
end
for i=find(rankCon==inf) % Erase unmatched constraints from the adjacency matrix
    adjacency(numVars+i,:) = zeros(1,numVars+numCons);
    adjacency(:,numVars+i) = zeros(numVars+numCons,1);
end

for i=1:size(edges,1)
    adjacency(edges(i,1),numVars+edges(i,2)) = 0; % Delete edges from vars to cons
    adjacency(numVars+edges(i,2),:) = 0; % For matching constraints, delete all outwards arrows...
    adjacency(numVars+edges(i,2),edges(i,1)) = 1; % ... except for the matchings
    adjacency(numVars+indexRes,:) = 0; % Delete all outward edges from residual generators
end

% Add residuals vars in the adjacency matrix
adjRes = zeros(numCons,numRes);
for i=1:numRes
    adjRes(indexRes(i),i) = 1;
end

residualLabels = cell(1,numRes); % Construct node labels
for i=1:length(residualLabels)
    residualLabels{i}=sprintf('R%s',Graph.constraints{indexRes(i)});
end
nodeLabels = {Graph.vars{:}, Graph.constraints{:}, residualLabels{:}};

% Add the residual nodes in the adjacency matrix
tempArray = [zeros(numVars,numRes); adjRes];
adjacency = [adjacency tempArray; zeros(numRes, numVars+numCons+numRes)];

GraphM = Graph;
GraphM.adjacency = adjacency;
GraphM.res = residualLabels;
% GraphM.isMatched = ?

% Initialize the set containing the coordinates of each node
coords = -ones(numVars+numCons+numRes,2);

for i=0:(max(rankVar(isfinite(rankVar)))+1) % for the matched variable ranks
    vars2plot = find(rankVar==i); % find the variables of the current rank
    for j=1:length(vars2plot)
        coords(vars2plot(j),1)=i;
        coords(vars2plot(j),2)=j;
    end
    cons2plot = find(rankCon==i);
    for j=1:length(cons2plot)
        coords(cons2plot(j)+numVars,1)=i+0.5;
        coords(cons2plot(j)+numVars,2)=j+0.6;
    end
    res2plot = find((rankCon==(i-1)).*residuals);
    for j=1:length(res2plot)
        coords(find(indexRes==res2plot(j))+numVars+numCons,1) = i;
        coords(find(indexRes==res2plot(j))+numVars+numCons,2) = j+length(vars2plot);
    end
end


coords(:,1) = coords(:,1)./max(coords(:,1));
coords(:,2) = coords(:,2)./max(coords(:,2));


%% Colour nodes
nodeColors = zeros(size(GraphM.adjacency,1),3);
for i=1:length(GraphM.vars)
    nodeColors(i,:) = yellow;
    if GraphM.isInput(i)
        nodeColors(i,:) = gray;
    end
end
for i=(length(GraphM.vars)+1):size(GraphM.adjacency,1)
    nodeColors(i,:) = blue;
end
for i=(numVars+numCons+1):(numVars+numCons+numRes)
    nodeColors(i,:) = green;
end


g = drawNetwork(adjacency, '-nodeLabels', nodeLabels, '-nodeColors', nodeColors);

for i=(numVars+1):numVars+numCons % Make constraints square
    g.nodeArray(i).curvature = [0,0];
end

g.tightenAxes;
diameter = max([g.nodeArray(:).width]); % Place nodes on grid
aspectRatio = 14/9;
coords = coords*(1-aspectRatio*diameter);
coords(:,1) = coords(:,1)*(1-aspectRatio*diameter); % Correcting for tight display bug
coords = coords+0.5*aspectRatio*diameter;
g.setNodePositions(coords); 
g.increaseFontSize;
g.increaseFontSize;

GraphM.coords = coords;

end

