% MATCHING_COMPARISON Script comparing the Branch & Bound ILP methodology against other algorithms from FDI literature
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% November 2018; Last revision: -

% This demo is a comparison between structural matching algorithms, specifically:
% * Reachable subgraph methodology from Flaugergues2009
% * Mixed matching methodology from Svard2010
% * Our BBILP methodology
% The methodologies are applied onto a fixed-wing UAV model subject to actuator and sensor faults.

% This demo script involves:
% * Generation of the Structural Models
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings with each methodology and timing the procedure

% INSTRUCTIONS:
% Simply run this script. The results will be plotted. Estimated duration is about 7mins, depending on your machine.


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
modelArray{end+1} = g005b(); % UAV model described in Fravolini, M., Campa, G., & Napolitano, M. (2008).

% Define the matching method set to test
matchMethodSet = {'BBILP','Flaugergues','Mixed'};

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
        SA_settings.maxSearchTime = 20; % Maximum allotted time per PSO to find a valid matching
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
            
            % Check matchings for validity
            [valid_pso_array, valid_matching_cell] = validateMatchings(SA_results, SA_settings);
            % Delete invalid residuals
            SA_results = deleteInvalidMatchings(SA_results, valid_pso_array);
            % Display matching statistics
            displayMatchingStatistics( SA_results, SA_settings, valid_pso_array, valid_matching_cell );
            
            %% Process statistics and save
            
            stats.(model.name) = SA_results.stats.(model.name);            
            
            stats.(model.name).num_valid_matchings = sum(cellfun(@(x)length(x), valid_matching_cell));
            stats.(model.name).num_valid_psos = sum(valid_pso_array);
            stats.(model.name).num_invalid_matchings = parseCellRecursive(SA_results.matchings_set) - stats.(model.name).num_valid_matchings;
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
                        oldStats.(newFieldName).timeSolveMatching = stats.(newFieldName).timeSolveMatching/recordedSamples + oldStats.(newFieldName).timeSolveMatching*(recordedSamples-1)/recordedSamples;
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


%% Benchmark comparisons between matching algorithms
% Plots the comparison results

clear
close all hidden

matchMethodSet = {'BBILP','Flaugergues', 'Mixed'};  % Should be the same as in the previous section
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
    point.time = stats.(model_name).timeSolveMatching;
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
ah.YLim = [0 350]; 
ah.XLim = [0 21]; 
% set(ah, 'YScale', 'log');
ah.YLabel.String = 'Time (s)'; 
ah.XLabel.String = sprintf('Number of PSOs with a Realizable Matching (Out of %d Total)',length(stats.(model_name).ResGenSets{1})); 

grid on
ah.GridColor = [0.2, 0.2, 0.2];  % [R, G, B] 
ah.GridAlpha = 0.3;