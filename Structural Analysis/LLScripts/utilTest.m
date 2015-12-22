%% A standard structural analysis workflow
close all;
clear all;
clc;

%% Create graph

global IDProviderObj;
IDProviderObj = IDProvider();

% Select a model file to create the cell structure
% [model, coords] = modelFile();
[model, coords] = g001();

% Create the graph object
mygraph = GraphBipartite(model,coords);
disp('Build graph object');

% Display the adjacency matrices
subplot(2,2,[1,3])
spy(mygraph.adjacency.BD);
subplot(2,2,2)
spy(mygraph.adjacency.E2V);
subplot(2,2,4)
spy(mygraph.adjacency.V2E);


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

% Investigate the graph attributes
cyclic = mygraph.hasCycles();
if cyclic 
    disp('The system graph is cyclic');
else
    disp('The system graph is not cyclic');
end
    