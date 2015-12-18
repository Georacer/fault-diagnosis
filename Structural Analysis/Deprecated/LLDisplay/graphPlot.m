function [ g, coords ] = graphPlot( Graph )
%MATCHINGPLOT Plot the matching of Graph
%   Variables are positioned in the units of x-axis
%   Constraints are positioned in the half-space between
%   A unit and the half-space on its right represent one rank
%   REQUIREMENTS: The graphviz4matlab library

gray = [0.3 0.3 0.3];
yellow = [1.0 1.0 0.0];
blue = [0.0 0.2 1.0];

numVars = length(Graph.vars);
numCons = length(Graph.constraints);

adjacency = Graph.adjacency;

nodeLabels = {Graph.vars{:}, Graph.constraints{:}};

% Colour nodes
nodeColors = zeros(size(Graph.adjacency,1),3);
for i=1:length(Graph.vars)
    nodeColors(i,:) = yellow;
    if Graph.isInput(i)
        nodeColors(i,:) = gray;
    end
end
for i=(length(Graph.vars)+1):size(Graph.adjacency,1)
    nodeColors(i,:) = blue;
end

% disp(size(adjacency));
% disp(size(nodeLabels));

g = drawNetwork(adjacency, '-nodeLabels', nodeLabels, '-nodeColors', nodeColors);

if (~isempty(Graph.coords))
    g.setNodePositions(Graph.coords);
end

for i=(numVars+1):(numVars+numCons) % Make constraints square
    g.nodeArray(i).curvature = [0,0];
end

% TODO: Colour matched nodes

g.tightenAxes;
diameter = max([g.nodeArray(:).width]); % Place nodes on grid
aspectRatio = 14/9;

coords = g.getNodePositions();

coords = coords*(1-aspectRatio*diameter);
coords(:,1) = coords(:,1)*(1-aspectRatio*diameter); % Correcting for tight display bug
coords = coords+0.5*aspectRatio*diameter;
g.setNodePositions(coords); 
g.increaseFontSize;
g.increaseFontSize;

end

