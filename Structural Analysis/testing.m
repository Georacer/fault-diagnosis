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

matcher = Matcher(graphOver);
matcher.setCausality('Realistic');
M = matcher.match('WeightedElimination','maxRank',3);
plotter = Plotter(graphOver);
% plotter.plotDM;
% plotter.plotDot('graphOver_matchedWeighted');

%%

clc

% Generate the remaining graph
sgOver = SubgraphGenerator(graphOver);
graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false),'postfix','_weightMatched');
fprintf('Done building submodel\n');

sgRemaining = SubgraphGenerator(graphRemaining);
sgRemaining.buildLiUSM();
fprintf('Done creating LiUSM model\n');

% Generate the subgraphs corresponding to the MTESs
sgRemaining.buildMTESs();
MTESs = sgRemaining.getMTESs();
fprintf('Done finding MTESs\n');

MTESsubgraphs = GraphInterface.empty;
plotters = Plotter.empty;
for i=1:length(MTESs)
    MTESsubgraphs(i) = sgRemaining.buildSubgraph(MTESs{i},'pruneKnown',true,'postfix','_MTES');
    plotters(i) = Plotter(MTESsubgraphs(i));
%     plotters(i).plotDot(sprintf('subgraph_%d',i));
end

% sg.buildMSOs();
% MSOs = sg.getMSOs();
% MSOs{1}
% subgraph = sg.buildSubgraph(MSOs{1});
%%
clc

% Extract all MSOs for each MTES subgraph
i=1;

MSOs = GraphInterface.empty;
plotters = Plotter.empty;
for i=1:length(MTESsubgraphs)
    gi = MTESsubgraphs(i);
    sg = SubgraphGenerator(gi);
    sg.buildLiUSM();
    sg.buildMSOs();
    tempMSOs = sg.getMSOs();
    for j=1:length(tempMSOs)
        MSOs(end+1) = sg.buildSubgraph(tempMSOs{j},'pruneKnown',true,'postfix',sprintf('MSO_%d',i));
        plotter = Plotter(MSOs(end));
        plotter.plotDot(sprintf('MSO_%d',i));
        i=i+1;
    end
end

MSOContainer = MSOs;

%% Get a valid matching for each MSO

clc

MSOs = copy(MSOContainer);

for i=1:length(MSOs)
    delete(matcher); matcher = Matcher(MSOs(i));
    edgeList = matcher.match('Valid');
    delete(tempPlotter); tempPlotter = Plotter(MSOs(i));
    tempPlotter.plotDot(sprintf('MSO_%d_matched',i));
end

%% Verify matching validity by size
for i=1:length(MSOs)
    
end
