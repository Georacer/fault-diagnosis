%MATCHINGINTRO - Demo script of basic matching procedures
%
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% March 2017; Last revision: 23/03/2017

clear
clc

%% Build the graph

model = g007();
initialGraph = GraphInterface();
initialGraph.readModel(model);
initialGraph.createAdjacency();

%% Perform Weighted Elimination

% Create a copy of the initial graph
graphWE = copy(initialGraph);

% Create a matcher object
matcher = Matcher(graphWE);

% Perform the matching
matching = matcher.match('WeightedElimination');

% Plot the result
plotter = Plotter(graphWE);
plotter.plotDot('matchedWE');

% Display the edges of the matching set and compare with plot
disp(matching);

%% Perform BBILP

% Create a copy of the initial graph
graphBBILP = copy(initialGraph);

% Create a subgraph generator
SG = SubgraphGenerator(graphBBILP);
% Build the LiUSM object to generate PSO sets
SG.buildLiUSM();
SG.buildMTESs();
PSOSet = SG.getMTESs();

% For each PSO, generate a new subgraph
PSOSubgraphs = GraphInterface.empty;
h = waitbar(0,'Building MTES Subgraphs');
for i=1:length(PSOSet)
    waitbar(i/length(PSOSet),h);
    PSOSubgraphs(i) = SG.buildSubgraph(PSOSet{i},'pruneKnown',true,'postfix','_MTES');
    PSOSubgraphs(i).createAdjacency();
end
close(h)

% Use the BBILP matcher to produce the cheapest valid matching for each PSO
matchers = Matcher.empty;
h = waitbar(0,'Examining PSOs');
for i=1:length(PSOSubgraphs)
    fprintf('\n');
    disp('Examining another PSOs')
    tempGI = PSOSubgraphs(i);
    matchers(i) = Matcher(tempGI);
    matching = matchers(i).match('BBILP','branchMethod','cheap');
    waitbar(i/length(PSOSubgraphs),h);
end
close(h)

% Display the mathcings
fprintf('\nResulting valid matchings:\n');
for i=1:length(matchers)
    disp(matchers(i).matchingSet);
end
