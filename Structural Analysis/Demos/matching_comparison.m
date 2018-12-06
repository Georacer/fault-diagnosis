% MATCHING_COMPARISON Script comparing the Branch & Bound ILP methodology against other algorithms from FDI literature
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% November 2018; Last revision: -

% FIXME
% This demo is a comparison between the classical, exhaustive approach of extracting valid residual generators from
% Structurally Overdetermined subgraphs, applied on Structural Graphs.
% The comparison is done in terms of matching methodology ( Branch and Bound ILP vs Exhaustive search) and Structurally
% Overdetermined search selection (MTES vs MSO).
% Many system models, pulled from relevant literature are used in the comparison.

% FIXME
% This demo script involves:
% * Generation of the Structural Models
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph

% FIXME
% INSTRUCTIONS:
% Simply run this script. The results will be plotted. Estimated duration is about 3mins, depending on your machine.


close all hidden
clear
clc

%% Setup program execution

% Select the mode of operation. 'breaking' will halt execution in every significant step.
opMode = 'continuous';
% opMode = 'breaking';

% Initialize the model container
modelArray = {};

% Select the models to test
% modelArray{end+1} = g005a(); % UAV model described in Fravolini, M., Campa, G., & Napolitano, M. (2008).
modelArray{end+1} = g005b();
% modelArray{end+1} = g014g();
% modelArray{end+1} = g039();
% modelArray{end+1} = g040();

% Define the matching method set to test
% matchMethodSet = {'BBILP','Flaugergues','Mixed'};
% matchMethodSet = {'BBILP'};
matchMethodSet = {'BBILP2'};
% matchMethodSet = {'Flaugergues'};
% matchMethodSet = {'Mixed'};

% Define the Structurally Overdetermined set of graphs to examine
SOTypeSet = {'MTES'};

% The branch selection strategy for BBILP will be Depth-First Search
branchMethod = 'DFS';

%% Start program execution
for matchIndex = 1:length(matchMethodSet)
    matchMethod = matchMethodSet{matchIndex};
    
    for SOTypeIndex = 1:length(SOTypeSet)
        SOType = SOTypeSet{SOTypeIndex};
        
        % Build the options structure
        SA_settings.matchMethod = matchMethod;
        SA_settings.SOType = SOType;
        SA_settings.branchMethod = branchMethod;
        SA_settings.maxMSOsExamined = 0;
        SA_settings.exitAtFirstValid = true;
        SA_settings.plotGraphInitial = false;
        SA_settings.plotGraphOver = false;
        SA_settings.plotGraphRemaining = false;
        SA_settings.plotGraphDisconnected = false;
        SA_settings.plotGraphPSO = false;
        SA_settings.plotGraphMatched = true;
        
        % For each model
        for modelIndex=1:length(modelArray)
            
            close all;
            
            %% Read the model description and create the initial graph
            model = modelArray{modelIndex};
            
            %% Perform Structural Analsysis and Matching, extract residual generators
            SA_results = structural_analysis(model, SA_settings);
            
            %% Validate matchings
            % TODO Does not apply for graphs with disconnected subgraphs
            PSOs = SA_results.SOSubgraphs_set{1};
            matchings = SA_results.matchings_set{1};
            valid_matchings = 0;
            total_matching_array = zeros(1,length(matchings)); % Holds the total number of generated matchings
            valid_pso_array = zeros(1,length(PSOs));
            valid_matching_cell = cell(1,length(PSOs));
            graphInitial = SA_results.gi;
            
            for i=1:length(matchings)
                if isempty(matchings{i})
                    % No matching was found
                    continue;
                end        
                
                gi = PSOs(i);
                gi_blob = getByteStreamFromArray(gi); % Freeze a copy of this PSO
                matchings_this_pso = matchings{i};
                if ~iscell(matchings_this_pso)
                    matchings_this_pso = {matchings_this_pso};
                end
                total_matching_array(i) = length(matchings_this_pso);
                valid_matching_cell{i} = {};
                
                valid_found = false;
                
                for j=1:length(matchings_this_pso)
                    gi = getArrayFromByteStream(gi_blob); % Restore the PSO
                    m = matchings_this_pso{j};
                    gi.applyMatching(m); % Apply the current matching to it
                    
                    equIds = gi.getEquations(m);
                    varIds = graphInitial.getVariablesUnknown(equIds);
                    if length(varIds)~=length(equIds)
                        continue;
                    end

                    gi.createAdjacency();
                    adjacency = gi.adjacency;
                    numVars = gi.adjacency.numVars;
                    numEqs = gi.adjacency.numEqs;
                    validator = Validator(adjacency.BD, adjacency.BD_types, numVars, numEqs);
                    offendingEdges = validator.isValid();
                    if ~isempty(offendingEdges)
                        % Matching is not valid
                        continue;
                    end
                    % Mark this PSO as one with a valid matching
                    if ~valid_found
                        valid_pso_array(i) = 1;
                        valid_found = true;
                    end
                    
                    valid_matchings = valid_matchings + 1; % Cound the valid matchings
                    valid_matching_cell{i}{end+1} = m; % Store this valid matching in this PSO container
%                     break; % One valid matching was found for this PSO. This is enough
                end
            end
            
%             fprintf('Valid matchings %d/%d\n',valid_matchings, length(matchings));
            
            %% Display the total number of residual generators found
            
            fprintf('Matching Statistics for system %s with method %s\n',model.name, matchMethod);
            fprintf('================================================\n');
            
            fprintf('Number of PSOs with valid matchings: %d/%d\n',sum(valid_pso_array),length(valid_pso_array));
            
            graphName = SA_results.gi.name;
            
            % Average PSO size
            numSets = 0;
            for i=1:length(SA_results.stats.(graphName).ResGenSets)
                numSets = numSets + length(SA_results.stats.(graphName).ResGenSets{i});
            end
%             fprintf('Total number of PSOs: %d\n',numSets);
            
            total = 0;
            for j=1:length(SA_results.stats.(graphName).ResGenSets)
                for i=1:length(SA_results.stats.(graphName).ResGenSets{j})
                    total = total+length(SA_results.stats.(graphName).ResGenSets{j}{i});
                end
            end
            avgSize = total/numSets;
            fprintf('Average PSO size: %g\n',avgSize);
            
            % Average matching size
            total = 0;
            for i=1:1
                for j=1:length(valid_matching_cell) % Select subgraph
                    matchings_this_pso = valid_matching_cell{j}; % Select PSO
                    for k=1:length(matchings_this_pso) % Select matching
                        matching = matchings_this_pso{k};
                        if ~isempty(matching)
                            total = total+length(matching);
                        else
                        end
                    end
                end
            end
            avgSize = total/valid_matchings;
            fprintf('Number of resulting valid matchings: %d\n',valid_matchings);
            fprintf('Mean matching size: %g\n',avgSize);
            fprintf('Number of invalid matchings: %d\n',sum(total_matching_array)-valid_matchings);
            fprintf('\n');
            
            if strcmp(opMode,'breaking')
                input('Press Enter to proceed to the next step...');
                clc
            end
            
            % Initial PSO matching statistics
            if exist('offendingInitial','var')
                validInitial = sum(cellfun(@(x) isempty(x),offendingInitial));
                fprintf('Number of valid initial, relaxed matchings: %d\n', validInitial);
                
                counterInt = 0;
                counterDer = 0;
                counterNI = 0;
                for i=1:length(offendingInitial)
                    edgesOffending = offendingInitial{i};
                    if isempty(edgesOffending)
                        continue;
                    end
                    if any(SA_results.gi.isDerivative(edgesOffending))
                        counterDer = counterDer+1;
                    end
                    if any(SA_results.gi.isIntegral(edgesOffending))
                        counterInt = counterInt+1;
                    end
                    if any(SA_results.gi.isNonSolvable(edgesOffending))
                        counterNI = counterNI+1;
                    end
                end
                
                fprintf('Number of initial matching containing invalid derivative edges: %d\n',counterDer);
                fprintf('Number of initial matching containing invalid integral edges: %d\n',counterInt);
                fprintf('Number of initial matching containing invalid non-invertible edges: %d\n',counterNI);
                
            end
            
            %% Process statistics and save
            
            stats.(model.name) = SA_results.stats.(graphName);            
            
            stats.(model.name).num_valid_matchings = valid_matchings;
            stats.(model.name).num_valid_psos = sum(valid_pso_array);
            stats.(model.name).num_invalid_matchings = sum(total_matching_array) - valid_matchings;
            fileName = sprintf('%s.mat',matchMethod);
            
            % If no statistics have previously been saved
            if ~exist(fileName)
                fieldNames = fieldnames(stats);
                for i=1:length(fieldNames)
                    stats.(fieldNames{i}).samples = 1;
                end
                save(fileName,'stats');
                
            else % Load existing statistics and add another sample
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
                        assert(all(cellfun(@(x,y) isequal(x,y),stats.(newFieldName).matchingSets,oldStats.(newFieldName).matchingSets)),'Newer version of graph has different matchingSets');
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
            end
            
            
        end
        
    end
    
end

if strcmp(opMode,'breaking')
    input('Press Enter to proceed to the next step...');
    clc
end

return


%% Benchmark comparisons between matching algorithms
% Plots the comparison results

clear
close all hidden
 
% TODO: Generate automatically log filenames

matchMethodSet = {'BBILP','Flaugergues', 'Mixed'};
point_graphic = {'s', '^', 'd'};
methodTitle = {'BBILP','Reachable SubGraph', 'Mixed Causality'};

file_names = {};
for matching_string = matchMethodSet
   file_names{end+1} = sprintf('%s.mat',matching_string{1});
end
names = {'g005b'}; 
text_offset = [20 20];

data = cell(1,length(file_names));
model_name = names{1};

for i=1:length(data)
    clear stats 
    point.name = methodTitle{i};
    load(file_names{i}); 
    point.num_valid_psos = stats.(model_name).num_valid_psos;
    point.time = stats.(model_name).timeSolveILP;
    point.graphic = point_graphic{i};
    data{i} = point;
end

fh = figure();
ah = gca;
hold on
for i=1:length(data)
    point = data{i};
    scatter(point.num_valid_psos, point.time, 100, point.graphic, 'filled');
    text(point.num_valid_psos, point.time + text_offset(2), point.name, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 12);
end
%  
% Set axis properties 
ah = fh.Children; 
ah.YLim = [0 400]; 
ah.XLim = [2 7]; 
% set(ah, 'YScale', 'log');
ah.YLabel.String = 'Time (s)'; 
ah.XLabel.String = sprintf('Number of PSOs with a Realizable Matching (Out of %d Total)',length(stats.(model_name).ResGenSets{1})); 

grid on
ah.GridColor = [0.2, 0.2, 0.2];  % [R, G, B] 
ah.GridAlpha = 0.3;