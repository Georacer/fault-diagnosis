close all;
clear all;
clc;
global IDProviderObj;
IDProviderObj = IDProvider();

% [model, coords] = modelFile();
[model, coords] = g001();

mygraph = GraphBipartite(model,coords);

subplot(2,2,[1,3])
spy(mygraph.adjacency.BD);
subplot(2,2,2)
spy(mygraph.adjacency.E2V);
subplot(2,2,4)
spy(mygraph.adjacency.V2E);

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

mygraph.plotDot();