function [ graph ] = createGraph( graphName, dimension )
%UNTITLED Create a graph from the provided model description
%   Detailed explanation goes here

if strcmp(graphName,'random')
    fprintf('Creating a new random graph\n');
    model = randomGraph(dimension(1),dimension(2));
else
    fprintf('Loading model %s\n',graphName);
    model = feval(sprintf('%s',graphName));
end

if exist(sprintf('%s/costlist.mat',graphName),'file');
    load(sprintf('%s/costlist.mat',graphName));
end

% Create the graph object
graph = GraphBipartite(model);
disp('Built graph object');

if ~exist('costList','var')
    disp('No cost list found in the workspace, creating a default one');
    costList = graph.createCostList(true);
end

graph.readCostList(costList);

%% Create the incidence matrix
graph.createAdjacency();

%% Create Linkopping University structural model
graph.createLiusm();
fprintf('LiU SM Linter output:\n');
graph.liusm.Lint();

% Create the simulation engine object to build the functions list
% simEngine = SimEngine(mygraph); 
% You can now discrad the SimEngine object and create another one based on
% the matched GraphBipartite

end

