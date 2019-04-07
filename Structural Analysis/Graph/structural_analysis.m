function [ results ] = structural_analysis( model, SAsettings )
%STRUCTURAL_ANALYSIS Perform structural analysis
% This function accepts a model description and
% 1. Generates a graph structure, representing the structural model of the
%   input model
% 2. Breaks the initial graph into its disconnected subgraphs for 
%   reduction of complexity
% 3. Generates all Proper Structurally Overdetermined graphs, which allow
%   fault diagnosis
% 4. Finds a matching for each PSO, which leads to a residual generator
%
% INPUTS:
% model:            Input model object, generated from the GraphPool
% SASettings:
%   matchmMethod:   The PSO matching method
%   SOType:         The desired PSO type to be discovered
%   branchMethod:   In case BBILP matching is used, the desired branching
%                   method
%   plotGraphInitial: Plot initial sturctural graph
%   plotGraphDisconnected: Plot all disconnected subgraphs
%   plotGraphPSO:   Plot all PSO subgraphs
%   plotGraphMatched: Plot all matched PSOs

% Parse the settings
matchMethod = SAsettings.matchMethod;
SOType = SAsettings.SOType;
branchMethod = SAsettings.branchMethod;
maxMSOsExamined = SAsettings.maxMSOsExamined;
exitAtFirstValid = SAsettings.exitAtFirstValid;
maxSearchTime = SAsettings.maxSearchTime; % Maximum search time for a matching in each PSO
plotGraphInitial = SAsettings.plotGraphInitial;
plotGraphOver = SAsettings.plotGraphOver;
plotGraphRemaining = SAsettings.plotGraphRemaining;
plotGraphDisconnected = SAsettings.plotGraphDisconnected;
plotGraphPSO = SAsettings.plotGraphPSO;
plotGraphMatched = SAsettings.plotGraphMatched;

tic;
graphInitial = GraphInterface(); % Instantiate a GraphInterface
graphInitial.readModel(model); % Create the structural model
graphInitial.createAdjacency(); % Also create the adjacency matrix

% If matchMethod = Flaugergues, the initial model needs to be modified.
if strcmp(matchMethod,'Flaugergues')
    sg = SubgraphGenerator(graphInitial);
    graph = sg.flaugergues();
else
    graph = graphInitial;
end

timeCreateGI = toc; % Save the creattion time

% Create a GraphViz plot of the initial graph in the model folder
if plotGraphInitial
    plotter = Plotter(graph);
    plotter.plotDot('initial');
end

fprintf('Done building initial model %s\n',graphInitial.name);
name = graphInitial.name;

stats.(name).name = name;
stats.(name).timeCreateGI = timeCreateGI;
stats.(name).num_valid_matchings = 0;
stats.(name).num_invalid_matchings = 0;

%% Create the overconstrained graph

sgInitial = SubgraphGenerator(graph); % Create a SubgraphGenerator based on the initial model
sgInitial.buildLiUSM(); % Generate the LiUSM object
fprintf('Done creating initial LiUSM model\n');
graphOver = sgInitial.getOver(); % Build the overconstrained part as a separate graph
% Create a GraphViz plot of the overconstrained graph in the model folder
if plotGraphOver
    plotter = Plotter(graphOver);
    plotter.plotDot('overconstrained');
end

%% Perform weighted matching up to a rank, if needed

% For selected very large models, match 1 rank of variables to reduce the model
% size and complexity
switch model.name
    case {'g014e'}
        matchWERank = 1;
    otherwise
        matchWERank = 0;
end
if matchWERank > 0
    matcher = Matcher(graphOver); % Instantiate a Matcher object
    matcher.setCausality('Realistic'); % Set the desired causality
    M = matcher.match('WeightedElimination','maxRank',matchWERank); % Perform the matching
    % Set any matched variables as known, so that the LiUSM model will treat them as inputs
    matchedVarIds = graphOver.getVariables(M);
    graphOver.setKnown(matchedVarIds);
    
    % Generate the remaining graph from the remaining unmatched equations
    sgOver = SubgraphGenerator(graphOver);
    graphRemaining = sgOver.buildSubgraph(graphOver.getEquIdByProperty('isMatched',false),'postfix','_weightMatched');
    fprintf('Done building rank-matched submodel\n');
    
    sgRemaining = SubgraphGenerator(graphRemaining);
    sgRemaining.buildLiUSM();
    fprintf('Done creating rank-matched LiUSM model\n');
    
else % No need to perform initial weighted matching
    graphRemaining = graphOver;
    sgRemaining = SubgraphGenerator(graphRemaining);
    sgRemaining.buildLiUSM();    
end

% Create a GraphViz plot of the remaining graph in the model folder
if plotGraphRemaining
    plotter = Plotter(graphRemaining);
    plotter.plotDot('remaining');
end

% Make a rough estimate on the number of MTES that will be generated
mtes_sum = 0;
for k=0:(sgRemaining.liUSM.Redundancy-1)
    if k <= sgRemaining.liUSM.nf
        mtes_sum = mtes_sum + nchoosek(sgRemaining.liUSM.nf, k);
    end
end
fprintf('The original graph could contain up to %d MTESs\n',mtes_sum);
fprintf('Proceeding to break it up into non-connected subgraphs...\n');

%% Break the graph down into its weakly connected components
% This makes the parsing and matching cheaper

tic
graphs_conn = getDisconnected(graphRemaining);  % Get the Weakly Connected Components
timeGetDisconnected = toc;
fprintf('Found disconnected subsystems in %gs\n',timeGetDisconnected);
stats.(name).timeGetDisconnected = timeGetDisconnected;

% Preallocate container structures
SOSubgraphs_set = cell(1,length(graphs_conn));
res_gens_set = cell(1,length(graphs_conn));
matchings_set = cell(1,length(graphs_conn));

% For each Weakly Connected Component
for graph_index=1:length(graphs_conn)
    
    % This is the currently examined graph
    graph = graphs_conn{graph_index};
    
    % Check if this subgraph actually has any faults % TODO: Place this under a conditional?
    if isempty(graph.getEquIdByProperty('isFaultable'))
        continue;
    end
    
    sg = SubgraphGenerator(graph);
    sg.buildLiUSM(); % Build the LiUSM model
    
    % Plot the current WCC
    if plotGraphDisconnected
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
        case 'MSO' % Use Minimal Structurally Overdetermined sets
            sg.buildMSOs(); % Use the LiUSM algorithm to find the MSOs
            ResGenSets = sg.getMSOs(); % Get the equations sets corresponding to the MSOs
            % Count and save the number of MSOs discovered
            initialMSONum = length(ResGenSets);
            stats.(name).initialMSONum(graph_index) = initialMSONum;
            % Keep only faultable ones
            for i=initialMSONum:-1:1
                if ~any(graph.isFaultable(ResGenSets{i}))
                    ResGenSets(i) = [];
                end
            end
        case 'MTES' % Use Minimum Test Equation Support sets
            sg.buildMTESs(); % Use the LiUSM algorithm to find the MTESs
            ResGenSets = sg.getMTESs(); % Get the equations sets corresponding to the MTESs
    end
    timeSetGen = toc
    stats.(name).timeSetGen(graph_index) = timeSetGen; % Save the PSO generation time statistic
    
    % Store the PSO set
    stats.(name).ResGenSets{graph_index} = ResGenSets;
    res_gens_set{graph_index} = ResGenSets;
    
    fprintf('Done finding MSOs/MTESs\n');    
    
    %% Build the subgraphs corresponding to each PSO (the SOSubgraphs array)
    % i.e. use the acquired set of equation ids to create a subgraph for
    % each PSO
    tic
    SOSubgraphs = GraphInterface.empty;
    h = waitbar(0,'Building SO Subgraphs');
    
    % For each Structurally Overdetermined set
    for i=1:length(ResGenSets)
        waitbar(i/length(ResGenSets),h);
        
        % Build the subraph generator
        if strcmp(SOType,'MTES')
            postfix = '_MTES';
        elseif strcmp(SOType,'MSO')
            postfix = '_MSO';
        else
            error('Unknown SO type');
        end
        SOSubgraphs(i) = sg.buildSubgraph(ResGenSets{i}, 'pruneKnown', true, 'postfix', postfix);
        SOSubgraphs(i).createAdjacency();
        
        % MTESs may have disconnected components, which need to be removed
        % Only keep the connected component of each MTES which is faultable
        if strcmp(SOType,'MTES')
            % Build the undirected biadjacency matrix of the graph
            tempArray =  SOSubgraphs(i).adjacency.V2E;
            matrix = [zeros(size(tempArray,1)) tempArray ; tempArray' zeros(size(tempArray,2)) ];
            
            conn_comps = find_conn_comp(matrix); % Find all connected components
            equIds = SOSubgraphs(i).reg.equIdArray;
            varIds = SOSubgraphs(i).reg.varIdArray;
            counterFaultable = 0;
            % For each conncted component, check if any one has a faultable
            % equation
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
            % This should not happen, since this means it is actually two
            % separate MTESs
            if counterFaultable > 1
                error('MTES %d found with more than one faultable connected component', i);
            end
        end
        
        stats.(name).subsystems(graph_index) = {SOSubgraphs(i).reg.subsystems}; % Populate subsystems data
        

        if plotGraphPSO
            plotter = Plotter(SOSubgraphs(i));
            plotter.plotDot(sprintf('wcc_%d_so_%d', graph_index, i));
        end
        
    end
    
    close(h)
    timeMakeSG = toc
    stats.(name).timeMakeSG(graph_index) = timeMakeSG; % Store the time the SO graph generation procedure took
    
    %% Matching Procedure
    
    matchers = Matcher.empty;
    % For each subgraph
    h = waitbar(0,'Examining SO graph');
    
    tic;
    
    SOindices = 1:length(SOSubgraphs);
    
    stats.(name).PSOSolutionTimes = zeros(1,length(SOindices));
    
    % Iterate over all Structurally Overconstrained sets
    for i=1:length(SOindices)
        tic
        index = SOindices(i);
        fprintf('\n');
        tempGI = SOSubgraphs(index);
        fprintf('Examining SO graph %d/%d with size %d\n', i, length(SOindices), length(tempGI.reg.equIdArray));
        matchers(i) = Matcher(tempGI, maxSearchTime); % Instantiate the matcher for this SO
        switch matchMethod
            case 'BBILP' % Use the BBILP method to match
                matching = matchers(i).match('BBILP','branchMethod',branchMethod);
            case 'BBILP2' % Use the BBILP method to match
                matching = matchers(i).match('BBILP2','branchMethod',branchMethod,'exitAtFirstValid',exitAtFirstValid);
            case {'Exhaustive','Flaugergues'} % Use the exhaustive method to match
                matching = matchers(i).match('Valid2','maxMSOsExamined',maxMSOsExamined,'exitAtFirstValid',exitAtFirstValid);
            case {'SVE'} % Use the exhaustive method to match
                matching = matchers(i).match('SVE');
            case {'Mixed'} % Use the Mixed causality matching from Svard2010
                matching = matchers(i).match('Mixed','exitAtFirstValid',exitAtFirstValid);
            otherwise
                error('Unknown match method %s',matchMethod);
        end
        matchings_set{graph_index}(i) = {matchers(i).matchingSet};
        % Store stat about valid matching
        if ~isempty(matchers(i).matchingSet)
            stats.(name).num_valid_matchings = stats.(name).num_valid_matchings + 1;
        else
            stats.(name).num_invalid_matchings = stats.(name).num_invalid_matchings + 1;
        end
        
        waitbar(i/length(SOSubgraphs),h);
        
        PSOSolutionTime = toc;
        fprintf('Time required to solve this PSO: %fs\n',PSOSolutionTime);
        stats.(name).PSOSolutionTimes(i) = PSOSolutionTime;
        
        % Plot resulting matchings
        if ~isempty(matching) % Skip if no matching was feasible
            SOSubgraphs(index).adjacency.parseModel(); % Build the adjacency matrix
            
            if plotGraphMatched
                plotter = Plotter(tempGI);
                plotName = sprintf('wcc_%d_so_%d_matched', graph_index, index);
                plotter.plotDot(plotName);
            end
        end
    end
    
    % Store the stat about matching time
    timeSolveMatching = sum(stats.(name).PSOSolutionTimes);    
    stats.(name).timeSolveMatching(graph_index) = timeSolveMatching;
    close(h)
    
    % Printout the matchings found for this WCC
    fprintf('\nResulting matchings:\n');
    for i=1:length(matchers)
        disp(matchers(i).matchingSet);
        stats.(name).matchingSets{graph_index}(i) = {matchers(i).matchingSet};
        %     printMatching(MTESsubgraphs(i),matchers(i).matchingSet);
    end
    
    % Store the matched/directed SO in the container across all WCC graphs
    SOSubgraphs_set{graph_index} = SOSubgraphs;
    
end

%% Populate the result

% Some of the fields contain redundant information
results.gi = graphInitial; % The initial structural graph
results.stats = stats; % Various (time) statistics
results.SOSubgraphs_set = SOSubgraphs_set; % The matched/directed subgraphs
results.res_gens_set = res_gens_set; % The sets of equation ids making up the SOs
results.matchings_set = matchings_set; % The sets of edges making up the matchings

return

end
