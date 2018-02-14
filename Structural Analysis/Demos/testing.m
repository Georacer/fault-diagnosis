%% Testing
% TESTING Test script for the residual discovery capabilitites.


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

% modelArray{end+1} = g014g();
% modelArray{end+1} = g014h();
% modelArray{end+1} = g008();
% modelArray{end+1} = g021();
% modelArray{end+1} = g022();
% modelArray{end+1} = g023();
% modelArray{end+1} = g024();
% modelArray{end+1} = g024a();
% modelArray{end+1} = g025();
% modelArray{end+1} = g026();
% modelArray{end+1} = g005();
% modelArray{end+1} = g005a();
% modelArray{end+1} = g027();
% modelArray{end+1} = g028();
% modelArray{end+1} = g029();
% modelArray{end+1} = g030();
% modelArray{end+1} = g031();
% modelArray{end+1} = g032();
modelArray{end+1} = g033();
% modelArray{end+1} = g034();

matchMethod = 'BBILP';
% matchMethod = 'Exhaustive';

SOType = 'MTES';
% SOType = 'MSO';

% branchMethod = 'cheap';
branchMethod = 'DFS';
% branchMethod = 'BFS';

% For each model
for modelIndex=1:length(modelArray)
    % Read the model description and create the initial graph
    clc
    clearvars -except stats modelIndex modelArray SOType branchMethod matchMethod
    model = modelArray{modelIndex};
    
    graphInitial = GraphInterface();
    graphInitial.readModel(model);
    graphInitial.createAdjacency();
    plotter = Plotter(graphInitial);
    % plotter.plotDM;
%     plotter.plotDot('initial');
    fprintf('Done building model %s\n',graphInitial.name);
    name = graphInitial.name;
    
    stats.(name).name = name;
    
    sgInitial = SubgraphGenerator(graphInitial);
    sgInitial.buildLiUSM();
    fprintf('Done creating LiUSM model\n');
    graphOver = sgInitial.getOver();
    
    %% Perform weighted matching up to a rank, if needed
    % For very large models, match 1 rank of variables to reduce the model
    % size and complexity
    switch model.name
        case {'g014e'}
            matchWERank = 1;
            %             matchWERank = 0;
        otherwise
            matchWERank = 0;
    end
    
    if matchWERank > 0
        matcher = Matcher(graphOver);
        matcher.setCausality('Realistic');
        M = matcher.match('WeightedElimination','maxRank',matchWERank);
        plotter = Plotter(graphOver);
        % plotter.plotDM;
        % plotter.plotDot('graphOver_matchedWeighted');
                
        % Generate the remaining graph
        sgOver = SubgraphGenerator(graphOver);
        graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false),'postfix','_weightMatched');
        sgOver.buildLiUSM();
        fprintf('Done building submodel\n');
        
        sgRemaining = SubgraphGenerator(graphRemaining);
        sgRemaining.buildLiUSM();
        fprintf('Done creating LiUSM model\n');
        
        plotterGR = Plotter(graphRemaining);
        %     plotterGR.plotDM;
        
    else
        graphRemaining = graphOver;
        
    end
    
    %% Break the graph down into its weakly connected components
    % This makes the parsing cheaper
    
    % Preallocate container structures
    graphs_conn = getDisconnected(graphRemaining);  % Get the Weakly Connected Componentss
    SOSubgraphs_set = cell(1,length(graphs_conn));
    matchers_set = cell(1,length(graphs_conn));
    
    % For each WCC
    for graph_index=1:length(graphs_conn)
        
        % This is the currently examined graph
        graph = graphs_conn{graph_index};
        plotter = Plotter(graph);
        plotter.plotDot(sprintf('wcc_%d',graph_index));
        sg = SubgraphGenerator(graph);
        sg.buildLiUSM();
        
        % Make a rough estimate on the number of MTES that will be generated
        sum = 0;
        for k=0:(sg.liUSM.Redundancy-1)
            if k <= sg.liUSM.nf
                sum = sum + nchoosek(sg.liUSM.nf, k);
            end
        end
        fprintf('Expecting to generate up to %d MTESs\n',sum);
        
        tic
        %% Find the PSOs of each graph, depending on selected method
        switch SOType
            case 'MSO'
                % Generate the subgraphs corresponding to the MSOs
                sg.buildMSOs();
                ResGenSets = sg.getMSOs();
                % Keep only faultable ones
                initialMSONum = length(ResGenSets);
                stats.(name).initialMSONum(graph_index) = initialMSONum;
                for i=initialMSONum:-1:1
                    if ~any(graph.isFaultable(ResGenSets{i}))
                        ResGenSets(i) = [];
                    end
                end
            case 'MTES'
                % Generate the subgraphs corresponding to the MTESs
                sg.buildMTESs();
                ResGenSets = sg.getMTESs();
        end
        timeSetGen = toc
        stats.(name).ResGenSets{graph_index} = ResGenSets;
        fprintf('Done finding MSOs/MTESs\n');
        
        stats.(name).timeSetGen(graph_index) = timeSetGen;
        %% Build the subgraphs corresponding to each PSO (the SOSubgraphs array)
        tic
        SOSubgraphs = GraphInterface.empty;
        plotters = Plotter.empty;
        h = waitbar(0,'Building MTES Subgraphs');
        
        % Sorting of PSOs by size
        PSOSize = cellfun(@(x) length(x), ResGenSets);
        [~, sortIndices] = sort(PSOSize);
        % OR
        %     sortIndices = 1:length(SOSubgraphs);
        
        for i=1:length(sortIndices)
            index = sortIndices(i);
            waitbar(i/length(ResGenSets),h);
            
            SOSubgraphs(i) = sg.buildSubgraph(ResGenSets{index},'pruneKnown',true,'postfix','_MTES');
            SOSubgraphs(i).createAdjacency();
            
            if SOType == 'MTES'
                % Only keep the connected component of each MTES which is
                % faultable
                tempArray =  SOSubgraphs(i).adjacency.V2E;
                matrix = [zeros(size(tempArray,1)) tempArray ; tempArray' zeros(size(tempArray,2)) ];
                conn_comps = find_conn_comp(matrix); % Find all connected components
                equIds = SOSubgraphs(i).reg.equIdArray;
                varIds = SOSubgraphs(i).reg.varIdArray;
                counterFaultable = 0;
                for j=1:length(conn_comps)
                    currentEquIndices = conn_comps{j}(conn_comps{j}>length(varIds))-length(varIds);
                    currentEquIds = equIds(currentEquIndices);
                    if any(SOSubgraphs(i).isFaultable(currentEquIds))
                        counterFaultable = counterFaultable + 1;
                    end
                end
                if j>1
                    warning('MTES %d found with more than one connected component', i);
                end
                if counterFaultable == 0
                    warning('MTES %d found with no faultable connected component', i);
                end
                if counterFaultable > 1
                    warning('MTES %d found with more than one faultable connected component', i);
                end
            end
            
            stats.(name).subsystems(graph_index) = {SOSubgraphs(i).reg.subsystems}; % Populate subsystems data
            %         plotters(i) = Plotter(SOSubgraphs(i));
            %         plotters(i).plotDot(sprintf('subgraph_%d',i));
        end
        close(h)
        timeMakeSG = toc
        stats.(name).timeMakeSG(graph_index) = timeMakeSG;
        
        
        %     return
        %% Matching Procedure
        %     clc
        
        matchers = Matcher.empty;
        plotters = Plotter.empty;
        counter = 1;
        % For each subgraph
        h = waitbar(0,'Examining SOs');
        
        tic
        profile on
        
        % Sorting of PSOs by size
        %     PSOSize = cellfun(@(x) length(x), ResGenSets);
        %     [~, sortIndices] = sort(PSOSize);
        %     % OR
        sortIndices = 1:length(SOSubgraphs);
        
        for i=1:length(sortIndices)
            index = sortIndices(i);
            fprintf('\n');
            disp('Examining another SOs')
            tempGI = SOSubgraphs(index);
            matchers(i) = Matcher(tempGI);
            switch matchMethod
                case 'BBILP'
                    matching = matchers(i).match('BBILP','branchMethod',branchMethod);
                case 'Exhaustive'
                    matching = matchers(i).match('Valid2');
            end
            waitbar(i/length(SOSubgraphs),h);
            % Plot resulting matchings
            if ~isempty(matching)
                SOSubgraphs(index).adjacency.parseModel();
                plotters(counter) = Plotter(tempGI);
                plotName = sprintf('%s_pso_%d_matched',SOSubgraphs(index).name, index);
%                 plotters(counter).plotDot(plotName);
                counter = counter + 1;
            end
        end
        
        timeSolveILP = toc
        stats.(name).timeSolveILP(graph_index) = timeSolveILP;
        close(h)
        profile off
        
        fprintf('\nResulting valid matchings:\n');
        for i=1:length(matchers)
            disp(matchers(i).matchingSet);
            stats.(name).matchingSets{graph_index}(i) = {matchers(i).matchingSet};
            %     printMatching(MTESsubgraphs(i),matchers(i).matchingSet);
        end
        
        % Store the results for the container across all WCC graphs
        SOSubgraphs_set{graph_index} = SOSubgraphs;
        matchers_set{graph_index} = matchers;
        
%         input('Press Enter to continue');
        
%         return
        
    end
    
    
end

% Display the total number of residual generators found
counter = 0;
for i=1:length(matchers_set)
    for j=1:length(matchers_set{i})
        if ~isempty(matchers_set{i}(j).matchingSet)
            counter = counter + 1;
        end
    end
end

fprintf('Total number of valid residuals found: %d\n',counter);

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
% stats.g005a
% stats.g014e

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