function plotG4M(obj)
% DEPRECATED!!! Plot graph using Graphviz4Matlab library

gray = [0.3 0.3 0.3];
yellow = [1.0 1.0 0.0];
blue = [0.0 0.2 1.0];

numVars = length(obj.variableArray);
numCons = length(obj.equationArray);
numEls = numVars + numCons;

nodeLabels = [obj.variableAliasArray obj.equationAliasArray];

% Colour nodes
nodeColors = zeros(numEls,3);
for i=1:numVars
    nodeColors(i,:) = yellow;
    if obj.variableArray(i).isInput
        nodeColors(i,:) = gray;
    end
end
for i=(numVars+1):numEls
    nodeColors(i,:) = blue;
end

% disp(size(adjacency));
% disp(size(nodeLabels));

obj.ph = drawNetwork(obj.adjacency.BD, '-nodeLabels', nodeLabels, '-nodeColors', nodeColors);

if (~isempty(obj.coords))
    obj.ph.setNodePositions(obj.coords);
end

for i=(numVars+1):numEls % Make constraints square
    obj.ph.nodeArray(i).curvature = [0,0];
end

% TODO: Colour matched nodes

obj.ph.tightenAxes;
diameter = max([obj.ph.nodeArray(:).width]); % Place nodes on grid
aspectRatio = 14/9;

obj.coords = obj.ph.getNodePositions();

obj.coords = obj.coords*(1-aspectRatio*diameter);
obj.coords(:,1) = obj.coords(:,1)*(1-aspectRatio*diameter); % Correcting for tight display bug
obj.coords = obj.coords+0.5*aspectRatio*diameter;
obj.ph.setNodePositions(obj.coords);
obj.ph.increaseFontSize;
obj.ph.increaseFontSize;

end