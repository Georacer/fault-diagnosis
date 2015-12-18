%% A standard structural analysis workflow
close all
clear

%% Create graph

% Select a model file to create the cell structure
[model, coords] = modelFile();
% model = benchmark();
% [model, coords] = g001();
% [model, coords] = g002();
% [model, coords] = g003();
% [model, coords] = g004();

% Create the graph object
Graph = modelParser(model);

% Display graph
[g, coordsDef] = graphPlot(Graph);
if (isempty(coords))
    coords = coordsDef;
end

g.setNodePositions(coords);
% Let the use re-arrange the nodes
disp('Rearrange node positions if needed and press ENTER');
pause();
coords = g.getNodePositions();
Graph.coords = coords;

%% Verify graph

% isCyclic = hasCycles(Graph); % Not implemented yet

%% Perform matching
matching = matchingRanking2(Graph);


%% Display mathcing and calculation order
[gm, coordsm, Graphm] = matchingPlot2(Graph,matching);