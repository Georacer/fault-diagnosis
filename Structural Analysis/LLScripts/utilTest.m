%% A standard structural analysis workflow1
close all;
clear all;
clc;

% profile on

%% Create graph

% Select a model file to create the cell structure
% [model, coords] = randomGraph(8,5);
% [model, name, coords] = g001();
% [model, coords] = g002();
% [model, coords] = g003();
% [model, coords] = g004();
% [model, name, coords] = g005();
% [model, coords] = g006();
% [model, name, coords] = g007();
% [model, name, coords] = g007a();
% [model, coords] = g008();
% [model, name, coords] = g009a();
% [model, name, coords] = g010();
% [model, name, coords] = g011();
% [model, name, coords] = g012();
% [model, name, coords] = g013();
[model, name, coords] = g014();

% Create the graph object
mygraph = GraphBipartite(model,name,coords);
disp('Built graph object');

if ~exist('costList')
    disp('No cost list found in the workspace');
    costList = mygraph.createCostList(true);
    disp('Fill in "costList" variable to add matching costs');
    disp('Hit return when done');
    pause();
end

mygraph.readCostList(costList);

return

%% Select causality
mygraph.causality = 'Mixed'; % None, Integral, Differential, Mixed, Realistic

%% Create the incidence matrix
mygraph.createAdjacency();

%% Create Linkopping University structural model
mygraph.createLiusm();
mygraph.liusm.Lint();

%% Plot the created graph
% Display the adjacency matrices
figure();
mygraph.plotSparse()

figure();
mygraph.liusm.PlotModel();
set(gca,'YTickLabel',mygraph.equationAliasArray);

figure();
mygraph.plotDM();



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
% mygraph.plotDot();

% return

%% Verify Graph
% % Investigate the graph attributes
% cyclic = mygraph.hasCycles();
% if cyclic 
%     disp('The system graph is cyclic');
% else
%     disp('The system graph is not cyclic');
% end
% 
% % return

%% Get over-constrained part
graphOver = mygraph.getOver();
% Create the incidence matrix
graphOver.createAdjacency();

% Create Linkopping University structural model
graphOver.createLiusm();
graphOver.liusm.Lint();

% Plot the created graph
% Display the adjacency matrices
figure();
graphOver.plotSparse()

figure();
graphOver.liusm.PlotModel();
set(gca,'YTickLabel',graphOver.equationAliasArray);

figure();
graphOver.plotDM();

%% Perform matching
profile on

graphOver.matchRanking('+');

profile viewer
profile off

return

%% Investigate residual signatures
fprintf('Building residual signature array:\n');
[signatures, generator_id] = mygraph.getResidualSignatures();

%% Display mathcing and calculation order
% mygraph.plotMatching();
mygraph.plotMatching2();


%% Cleanup routines

% profile viewer
% profile off