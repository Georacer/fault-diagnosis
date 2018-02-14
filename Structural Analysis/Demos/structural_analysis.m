function [ results ] = structural_analysis( model, SAsettings )
%STRUCTURAL_ANALYSIS General framework for structural analysis
%   Detailed explanation goes here

% Parse the settings
matchMethod = SAsettings.matchMethod;
SOType = SAsettings.SOType;
branchMethod = SAsettings.branchMethod;
plotGraphs = SAsettings.plotGraphs;

graphInitial = GraphInterface();
graphInitial.readModel(model);
graphInitial.createAdjacency();

% Create a GraphViz plot in the model folder
if plotGraphs
    plotter = Plotter(graphInitial);
    plotter.plotDot('initial');
end

fprintf('Done building initial model %s\n',graphInitial.name);
name = graphInitial.name;

stats.(name).name = name;

%% Create the overconstrained graph

sgInitial = SubgraphGenerator(graphInitial);
sgInitial.buildLiUSM();
fprintf('Done creating initial LiUSM model\n');
graphOver = sgInitial.getOver();
if plotGraphs
    plotter = Plotter(graphOver);
    plotter.plotDot('overconstrained');
end

%% Perform weighted matching up to a rank, if needed

% For very large models, match 1 rank of variables to reduce the model
% size and complexity
switch model.name
    case {'g014e'}
        matchWERank = 1;
    otherwise
        matchWERank = 0;
end

if matchWERank > 0
    matcher = Matcher(graphOver);
    matcher.setCausality('Realistic');
    M = matcher.match('WeightedElimination','maxRank',matchWERank);
    plotter = Plotter(graphOver);
    
    % Generate the remaining graph
    sgOver = SubgraphGenerator(graphOver);
    graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false),'postfix','_weightMatched');
    sgOver.buildLiUSM();
    fprintf('Done building rank-matched submodel\n');
    
    sgRemaining = SubgraphGenerator(graphRemaining);
    sgRemaining.buildLiUSM();
    fprintf('Done creating rank-matched LiUSM model\n');
    
    plotterGR = Plotter(graphRemaining);
    
else
    graphRemaining = graphOver;
    
end

%% Break the graph down into its weakly connected components
% This makes the parsing cheaper

% Preallocate container structures
graphs_conn = getDisconnected(graphRemaining);  % Get the Weakly Connected Componentss
SOSubgraphs_set = cell(1,length(graphs_conn));
res_gens_set = cell(1,length(graphs_conn));
matchings_set = cell(1,length(graphs_conn));

% For each WCC
for graph_index=1:length(graphs_conn)
    
    % This is the currently examined graph
    graph = graphs_conn{graph_index};
    sg = SubgraphGenerator(graph);
    sg.buildLiUSM();
    
    if plotGraphs
        plotter = Plotter(graph);
        plotter.plotDot(sprintf('wcc_%d',graph_index));
    end
    
    % Make a rough estimate on the number of MTES that will be generated
    mtes_sum = 0;
    for k=0:(sg.liUSM.Redundancy-1)
        if k <= sg.liUSM.nf
            mtes_sum = mtes_sum + nchoosek(sg.liUSM.nf, k);
        end
    end
    fprintf('Expecting to generate up to %d MTESs\n',mtes_sum);
    
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
    res_gens_set{graph_index} = ResGenSets;
    fprintf('Done finding MSOs/MTESs\n');
    
    stats.(name).timeSetGen(graph_index) = timeSetGen;
    %% Build the subgraphs corresponding to each PSO (the SOSubgraphs array)
    tic
    SOSubgraphs = GraphInterface.empty;
    h = waitbar(0,'Building MTES Subgraphs');
    
    SOindices = 1:length(ResGenSets);
    
    for i=1:length(SOindices)
        index = SOindices(i);
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
        
        if plotGraphs
            plotter = Plotter(SOSubgraphs(i));
            plotter.plotDot(sprintf('subgraph_%d',i));
        end
        
    end
    
    close(h)
    timeMakeSG = toc
    stats.(name).timeMakeSG(graph_index) = timeMakeSG;
    
    %% Matching Procedure
    
    %     clc
    
    matchers = Matcher.empty;
    counter = 1;
    % For each subgraph
    h = waitbar(0,'Examining SOs');
    
    tic
    profile on
    
    SOindices = 1:length(SOSubgraphs);
    
    % Iterate over all Structurally Overconstrained sets
    for i=1:length(SOindices)
        index = SOindices(i);
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
            
            if plotGraphs
                plotter = Plotter(tempGI);
                plotName = sprintf('%s_pso_%d_matched',SOSubgraphs(index).name, index);
                plotter.plotDot(plotName);
            end
            
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
        matchings_set{graph_index}(i) = {matchers(i).matchingSet};
    end
    
    % Store the results for the container across all WCC graphs
    SOSubgraphs_set{graph_index} = SOSubgraphs;
    
    %         input('Press Enter to continue');
    
end

%% Populate the result

% Some of the fields contain redundant information
results.gi = graphInitial;
results.stats = stats;
results.SOSubgraphs_set = SOSubgraphs_set;
results.res_gens_set = res_gens_set;
results.matchings_set = matchings_set;

return

end
