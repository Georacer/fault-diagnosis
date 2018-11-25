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


close all
clear
clc

%% Setup program execution

% Select the mode of operation. 'breaking' will halt execution in every significant step.
opMode = 'continuous';
% opMode = 'breaking';

% Initialize the model container
modelArray = {};

% Select the models to test
modelArray{end+1} = g005a(); % UAV model described in Fravolini, M., Campa, G., & Napolitano, M. (2008).

% Define the matching method set to test
% matchMethodSet = {'BBILP', 'Exhaustive'};
% matchMethodSet = {'Exhaustive'};
matchMethodSet = {'BBILP'};

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
        SA_settings.maxMSOsExamined = 1;
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
            
%             %% Validate matchings
%             % TODO Does not apply for graphs with disconnected subgraphs
%             PSOs = SA_results.SOSubgraphs_set{1};
%             matchings = SA_results.matchings_set{1};
% %             matchings = 
% %             graph_initial = SA_results.gi;
% %             binary_blob = getByteStreamFromArray(graph_initial);
% %             sg_initial = SubgraphGenerator(graph_intial, binary_blob);
%             valid_matchings = 0;
%             
%             for i=1:length(matchings)
%                 if isempty(matchings{i})
%                     % No matching was found
%                     break;
%                 end
%                 PSOs(i).createAdjacency();
%                 adjacency = PSOs(i).adjacency;
%                 numVars = PSOs(i).adjacency.numVars;
%                 numEqs = PSOs(i).adjacency.numEqs;
%                 validator = Validator(adjacency.BD, adjacency.BD_type, numVars, numEqs);
%                 offendingEdges = validator.isValid();
%                 if ~isempty(offendingEdges)
%                     % Matching is not valid
%                     break;
%                 end
%                 valid_matchings = valid_matchings + 1;
%             end
%             
%             fprintf('Valid matchings %d/%d\n',valid_matchings, length(matchings));
            
            %% Display the total number of residual generators found
            
            fprintf('Matching Statistics\n');
            fprintf('===================\n');
            counter = 0;
            for i=1:length(SA_results.matchings_set)
                for j=1:length(SA_results.matchings_set{i})
                    if ~isempty(SA_results.matchings_set{i}{j})
                        counter = counter + 1;
                    end
                end
            end
            
            fprintf('Total number of valid residuals found: %d\n',counter);
            
            graphName = SA_results.gi.name;
            
            % Average PSO size
            numSets = 0;
            for i=1:length(SA_results.stats.(graphName).ResGenSets)
                numSets = numSets + length(SA_results.stats.(graphName).ResGenSets{i});
            end
            fprintf('Total number of PSOs: %d\n',numSets);
            
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
            counterValid = 0;
            counterEmpty = 0;
            for i=1:length(SA_results.stats.(graphName).matchingSets)
                for j=1:length(SA_results.stats.(graphName).matchingSets{i})
                    matching = SA_results.stats.(graphName).matchingSets{i}{j};
                    if ~isempty(matching)
                        total = total+length(matching);
                        counterValid = counterValid + 1;
                    else
                        counterEmpty = counterEmpty + 1;
                    end
                end
            end
            avgSize = total/counterValid;
            fprintf('Number of valid matchings: %d\n',counterValid);
            fprintf('Mean matching size: %g\n',avgSize);
            fprintf('Number of invalid matchings: %d\n',counterEmpty);
            
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
            stats = SA_results.stats;
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
            end
            
            
        end
        
    end
    
end

if strcmp(opMode,'breaking')
    input('Press Enter to proceed to the next step...');
    clc
end

return


%% Benchmark comparisons between BBILP and exhaustive search
% Plots the comparison results

clear
close all 
 
% TODO: Generate automatically log filenames

matchMethodSet = {'BBILP','Valid2'};

file_names = {};
for matching_string = matchMethodSet
   file_names{end+1} = sprintf('%s.mat',matching_string{1});
end


% exhaustive_MTES = 'Exhaustive_DFS_MTES';
% BBILP_MTES = 'BBILP_DFS_MTES'; 
 
% files_MTES = {BBILP_MTES, exhaustive_MTES}; 
 
x1 = (1:3:(2*length(file_names)+1)) + 0.5; 
 
names = {'g005a'}; 
numExperiments = length(names); 
clear stats 
if length(x1==1)
    barWidth = 1;
else
    barWidth = 1/diff(x1(1:2)); 
end
 
% data_MTES = zeros(3,numExperiments); 
% data_MSO = data_MTES; 

data = zeros(length(file_names),2);

% Load MTES data 
timeSetGen = zeros(length(file_names),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(file_names) 
    load(file_names{i}); 
    for j=1:length(names)
        data(i,1) = stats.(names{j}).num_valid_matchings;
        data(i,2) = stats.(names{j}).num_invalid_matchings;
    end 
    clear stats 
end 
 
fh = figure(); 
 
h1 = barh([x1],[data],'stacked','BarWidth',barWidth); % this should make a stacked bar graph located at the x1 coordinates 
set(gca,'nextplot','add') %add on to the current graph 
 
% Set axis properties 
ah = fh.Children; 
ah.YLim = [0 7]; 
ah.XLim = [ah.XLim(1) ah.XLim(2)+2]; 
ah.YTick = 0:7; 
ah.YTickLabel = {'','','BBILP','','','Valid2','','',}; 
ah.YLabel.String = 'Matching Method'; 
ah.XLabel.String = 'Number of Residual Generators'; 
 
% Place explanatory text 
for i=1:length(x1) 
    x_coord = sum(data(i,:)); 
    text(x_coord+0.1,x1(i),'MTES'); 
end 
 
legend({names{:}},'Location','SE'); 
set(ah,'xgrid','on') 
ah.GridColor = [0.2, 0.2, 0.2];  % [R, G, B] 
ah.GridAlpha = 0.9;