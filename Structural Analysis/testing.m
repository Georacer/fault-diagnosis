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

matcher = Matcher(graphOver);
matcher.setCausality('Realistic');
M = matcher.match('WeightedElimination','maxRank',3);
plotter = Plotter(graphOver);
% plotter.plotDM;
plotter.plotDot('graphOver_matchedWeighted');

return

%%

clc

sgOver = SubgraphGenerator(graphOver);
graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false),'postfix','_weightMatched');
graphRemaining.createAdjacency();
fprintf('Done building submodel\n');

sgRemaining = SubgraphGenerator(graphRemaining);
sgRemaining.buildLiUSM();
fprintf('Done creating LiUSM model\n');

sgRemaining.buildMTESs();
MTESs = sgRemaining.getMTESs();
fprintf('Done finding MTESs\n');

MTESsubgraphs = GraphInterface.empty;
plotters = Plotter.empty;
for i=1:length(MTESs)
    MTESsubgraphs(i) = sgRemaining.buildSubgraph(MTESs{i},'pruneKnown',true,'postfix','_MTES');
    plotters(i) = Plotter(MTESsubgraphs(i));
    plotters(i).plotDot(sprintf('subgraph_%d',i));
end

% sg.buildMSOs();
% MSOs = sg.getMSOs();
% MSOs{1}
% subgraph = sg.buildSubgraph(MSOs{1});
%%
clc

i=1;
tempSG = SubgraphGenerator(MTESsubgraphs(i));
equIds = tempSG.gi.reg.equIdArray;
equIds2Keep = equIds(1:end-1);
tempGI = tempSG.buildSubgraph(equIds2Keep,'postfix','_MurtyTest'); % This should return a just-defined graph
delete(matcher); matcher = Matcher(tempGI);
M2 = matcher.match('Murty',1);
tempPlotter = Plotter(tempGI);
tempPlotter.plotDot('MurtyTest');