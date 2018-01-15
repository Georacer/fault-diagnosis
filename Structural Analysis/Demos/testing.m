% close all
clear
clc

% model = g007a();
% model = g014();
% model = g014f();
% model = g019();
% model = g020();

modelArray = {};
stats = [];

% Benchmarks:
% ---------------------
% * g014e(weR1)
% * ThreeTankAnalysis(FDT)(g008)
% * Commault(FDT)(g021)
% * Damadics(FDT)(g022)
% * ElectricMotor(FDT)(g023)
% * InductionMotor(FDT)(g024)
% * Raghuraj(FDT)(g025)
% * SmallLinear(FDT)(g026)
% * Fravolini(g005a)

% modelArray{end+1} = g014e();
modelArray{end+1} = g014g();
% modelArray{end+1} = g008();
% modelArray{end+1} = g021();
% modelArray{end+1} = g022();
% modelArray{end+1} = g023();
% modelArray{end+1} = g024();
% modelArray{end+1} = g025();
% modelArray{end+1} = g026();
% modelArray{end+1} = g005a();

matchMethod = 'BBILP';
% matchMethod = 'Exhaustive';

SOType = 'MTES';
% SOType = 'MSO';

% branchMethod = 'cheap';
branchMethod = 'DFS';
% branchMethod = 'BFS';

for modelIndex=1:length(modelArray)
    clc
    clearvars -except stats modelIndex modelArray SOType branchMethod matchMethod
    model = modelArray{modelIndex};
    
    graphInitial = GraphInterface();
    graphInitial.readModel(model);
    graphInitial.createAdjacency();
    plotter = Plotter(graphInitial);
    % plotter.plotDM;
    % plotter.plotDot('initial');
    fprintf('Done building model %s\n',graphInitial.name);
    name = graphInitial.name;
    
    stats.(name).name = name;
    
    sgInitial = SubgraphGenerator(graphInitial);
    sgInitial.buildLiUSM();
    fprintf('Done creating LiUSM model\n');
    
    % TODO: Must get overconstrained graph first
    graphOver = sgInitial.getOver();
    
    switch model.name
        case {'g014e', 'g014g'}
            matchWERank = 1;
        otherwise
            matchWERank = 0;
    end
    matcher = Matcher(graphOver);
    matcher.setCausality('Realistic');
    M = matcher.match('WeightedElimination','maxRank',matchWERank);
    plotter = Plotter(graphOver);
    % plotter.plotDM;
    % plotter.plotDot('graphOver_matchedWeighted');
    
    % return;
    %%
    
    % clc
    
    % Generate the remaining graph
    sgOver = SubgraphGenerator(graphOver);
    graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false),'postfix','_weightMatched');
    sgOver.buildLiUSM();
    fprintf('Done building submodel\n');
    
    sgRemaining = SubgraphGenerator(graphRemaining);
    sgRemaining.buildLiUSM();
    fprintf('Done creating LiUSM model\n');
    
    plotterGR = Plotter(graphRemaining);
    % plotterGR.plotDM;
    
    % return;
    
    tic
    switch SOType
        case 'MSO'
            % Generate the subgraphs corresponding to the MSOs
            sgRemaining.buildMSOs();
            ResGenSets = sgRemaining.getMSOs();
            % Keep only faultable ones
            initialMSONum = length(ResGenSets);
            stats.(name).initialMSONum = initialMSONum;
            for i=initialMSONum:-1:1;
                if ~any(graphRemaining.isFaultable(ResGenSets{i}));
                    ResGenSets(i) = [];
                end
            end
        case 'MTES'
            % Generate the subgraphs corresponding to the MTESs
            sgRemaining.buildMTESs();
            ResGenSets = sgRemaining.getMTESs();
    end
    timeSetGen = toc
    stats.(name).ResGenSets = ResGenSets;
    fprintf('Done finding MSOs/MTESs\n');
    
    stats.(name).timeSetGen = timeSetGen;
    
    tic
    SOSubgraphs = GraphInterface.empty;
    plotters = Plotter.empty;
    h = waitbar(0,'Building MTES Subgraphs');
    for i=1:length(ResGenSets)
        waitbar(i/length(ResGenSets),h);
        SOSubgraphs(i) = sgRemaining.buildSubgraph(ResGenSets{i},'pruneKnown',true,'postfix','_MTES');
        SOSubgraphs(i).createAdjacency();
        stats.(name).subsystems(i) = {SOSubgraphs(i).reg.subsystems}; % Populate subsystems data
        %     plotters(i) = Plotter(MTESsubgraphs(i));
        %     plotters(i).plotDot(sprintf('subgraph_%d',i));
    end
    close(h)
    timeMakeSG = toc
    stats.(name).timeMakeSG = timeMakeSG;
    
    
    % return
    %% Matching Procedure
    % clc
    
    matchers = Matcher.empty;
    plotters = Plotter.empty;
    % For each subgraph
    h = waitbar(0,'Examining SOs');
    
    tic
    profile on
    for i=1:length(SOSubgraphs)
        fprintf('\n');
        disp('Examining another SOs')
        tempGI = SOSubgraphs(i);
        matchers(i) = Matcher(tempGI);
        switch matchMethod
            case 'BBILP'
                matching = matchers(i).match('BBILP','branchMethod',branchMethod);
            case 'Exhaustive'
                matching = matchers(i).match('Valid2');
        end
        waitbar(i/length(SOSubgraphs),h);
        % Plot resulting matchings
        %     plotters(i) = Plotter(tempGI);
        %     plotters(i).plotDot(sprintf('MSO_%d_matched',i));
    end
    
    timeSolveILP = toc
    stats.(name).timeSolveILP = timeSolveILP;
    close(h)
    profile off
    
    fprintf('\nResulting valid matchings:\n');
    for i=1:length(matchers)
        disp(matchers(i).matchingSet);
        stats.(name).matchingSets(i) = {matchers(i).matchingSet};
        %     printMatching(MTESsubgraphs(i),matchers(i).matchingSet);
    end
    
    % input('Press Enter to continue');
    
    % return
    
end

return

%% Process statistics and save
fileName = sprintf('%s_%s_%s.mat',matchMethod, branchMethod,SOType);

if ~exist(fileName)
    fieldNames = fieldnames(stats);
    for i=1:length(fieldNames)
        stats.(fieldNames{i}).samples = 1;
    end
    save(fileName,'stats');
    return;
end
loadedData = load(fileName,'stats');
oldStats = loadedData.stats;
oldFieldNames = fieldnames(oldStats);

newFieldNames = fieldnames(stats);
for i=1:length(newFieldNames)
    newFieldName = newFieldNames{i};
    if ismember(newFieldName,oldFieldNames) % Existing graph model
        recordedSamples = oldStats.(newFieldName).samples + 1;
        oldStats.(newFieldName).samples = recordedSamples;
        assert(all(cellfun(@(x,y) isequal(x,y),stats.(newFieldName).ResGenSets,oldStats.(newFieldName).ResGenSets)),'Newer version of graph has different ResGenSets');
        assert(all(cellfun(@(x,y) isequal(x,y),stats.(newFieldName).matchingSets,oldStats.(newFieldName).matchingSets)),'Newer version of graph has differente matchingSets');
        oldStats.(newFieldName).timeSetGen = stats.(newFieldName).timeSetGen/recordedSamples + oldStats.(newFieldName).timeSetGen*(recordedSamples-1)/recordedSamples;
        oldStats.(newFieldName).timeMakeSG = stats.(newFieldName).timeMakeSG/recordedSamples + oldStats.(newFieldName).timeMakeSG*(recordedSamples-1)/recordedSamples;
        oldStats.(newFieldName).timeSolveILP = stats.(newFieldName).timeSolveILP/recordedSamples + oldStats.(newFieldName).timeSolveILP*(recordedSamples-1)/recordedSamples;
    else % New graph model
        oldStats.(newFieldName) = stats.(newFieldName);
        oldStats.(newFieldName).samples = 1;
    end
end
stats = oldStats;
save(fileName,'stats');

% stats.g008
stats.g005a
stats.g014e

return

%%
%%%%%%%%% Deprecated?

% Find which MSOs contain an integration, indicating dynamic loops
MTESsIndices_dynamic = [];
for i=1:length(MTESs)
    matchingSet = matchers(i).matchingSet;
    if ~isempty(matchingSet) && sum(graphInitial.isIntegral(matchingSet))
        MTESsIndices_dynamic(end+1,:) = [ i sum(graphInitial.isIntegral(matchingSet))];
    end
end

% Find which MSOs contain a NI edge, indicating AE loops
MTESsIndices_NI = [];
for i=1:length(MTESs)
    matchingSet = matchers(i).matchingSet;
    if ~isempty(matchingSet) &&  sum(graphInitial.isNonSolvable(matchingSet))
        MTESsIndices_NI(end+1,:) = [ i sum(graphInitial.isNonSolvable(matchingSet))];
    end
end