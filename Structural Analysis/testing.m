close all
clear
clc

graphInitial = GraphInterface();
% model = g007a();
model = g014e();
graphInitial.readModel(model);
graphInitial.createAdjacency();
plotter = Plotter(graphInitial);
% plotter.plotDM;
% plotter.plotDot('initial');
fprintf('Done building model\n');

sgInitial = SubgraphGenerator(graphInitial);
sgInitial.buildLiUSM();
fprintf('Done creating LiUSM model\n');

% TODO: Must get overconstrained graph first
graphOver = sgInitial.getOver();
graphOver.createAdjacency();
% plotter2 = Plotter(graphInitial);
% plotter.plotDM;
% plotter.plotDot('overconstrained');

matcher = Matcher(graphOver);
matcher.setCausality('Realistic');
M = matcher.match('WeightedElimination','maxRank',3);

%%

clc

sgOver = SubgraphGenerator(graphOver);
graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false));
graphRemaining.createAdjacency();
fprintf('Done building submodel\n');

sgRemaining = SubgraphGenerator(graphRemaining);
sgRemaining.buildLiUSM();
fprintf('Done creating LiUSM model\n');

sgRemaining.buildMTESs();
MTESs = sgRemaining.getMTESs();
fprintf('Done finding MTESs\n');

return

subgraphs = GraphInterface.empty;
plotters = Plotter.empty;
for i=1:length(MTESs)
    subgraphs(i) = sg.buildSubgraph(MTESs{i});
    plotters(i) = Plotter(subgraphs(i));
    plotters(i).plotDot(sprintf('subgraph_%d',i));
end

% sg.buildMSOs();
% MSOs = sg.getMSOs();
% MSOs{1}
% subgraph = sg.buildSubgraph(MSOs{1});
%%
close all
clear
clc

gi = GraphInterface();
gi.graph = GraphBipartite('name',gi);
gi.reg.setGraph(gi.graph);
[temp, equId] = gi.addEquation([],'eq1','k')

varProps.isKnown = true;
varProps.isMeasured = true;
varProps.isInput = false;
varProps.isOutput = false;
varProps.isResidual = false;
varProps.isMatched = false;
[temp, varId] = gi.addVariable([],'x1',varProps)


edgeProps.isMatched = false;
edgeProps.isDerivative = false;
edgeProps.isIntegral = false;
edgeProps.isNonSolvable = false;
[temp,edgeId] = gi.addEdge([],equId,varId,edgeProps);