%% A standard structural analysis workflow
close all;
clear all;
clc;

profile on

%% Create graph

% Select a model file to create the cell structure
% [model, coords] = modelFile();
% [model, coords] = g001();
% [model, coords] = g002();
% [model, coords] = g003();
% [model, coords] = g004();
[model, coords] = g005();

% Create the graph object
mygraph = GraphBipartite(model,coords);
disp('Built graph object');

% Display the adjacency matrices
mygraph.plotSparse()

% % Display the graph using Graphviz4Matlab
% mygraph.plotG4M();
% if (isempty(coords))
%     coords = mygraph.coords;
% end
% 
% % Let the use re-arrange the nodes
% disp('Rearrange node positions if needed and press ENTER');
% pause();
% coords = mygraph.ph.getNodePositions();
% mygraph.coords = coords;

% Display the graph using external dot compiler
mygraph.plotDot();

%% Verify Graph
% Investigate the graph attributes
cyclic = mygraph.hasCycles();
if cyclic 
    disp('The system graph is cyclic');
else
    disp('The system graph is not cyclic');
end

%% Perform matching
mygraph.matchRanking();

%% Investigate residual signatures
fprintf('Building residual signature array:\n');
[signatures, generator_id] = mygraph.getResidualSignatures();

%% Display mathcing and calculation order
mygraph.plotMatching();


%% Cleanup routines

profile viewer
profile off