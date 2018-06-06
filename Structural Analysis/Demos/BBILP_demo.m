% BBILP_DEMO Script showcasing the Branch and Bound Binary ILP matching methodology
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% March 2018; Last revision: May 2018

% This demo is a comparison between the classical, exhaustive approach of extracting valid residual generators from
% Structurally Overdetermined subgraphs, applied on Structural Graphs.
% The comparison is done in terms of matching methodology ( Branch and Bound ILP vs Exhaustive search) and Structurally
% Overdetermined search selection (MTES vs MSO).
% Many system models, pulled from relevant literature are used in the comparison.

% This demo script involves:
% * Generation of the Structural Models
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph

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

% Benchmarks:
% ---------------------
% * ThreeTankAnalysis(FDT)(g008)
% * Commault(FDT)(g021)
% * Damadics(FDT)(g022)
% * ElectricMotor(FDT)(g023)
% * InductionMotor(FDT)(g024)
% * Raghuraj(FDT)(g025)
% * SmallLinear(FDT)(g026)

% Select the models to test
modelArray{end+1} = g008();
modelArray{end+1} = g021();
modelArray{end+1} = g022();
modelArray{end+1} = g023();
modelArray{end+1} = g024();
modelArray{end+1} = g025();
modelArray{end+1} = g026();

% Define the matching method set to test
matchMethodSet = {'BBILP', 'Exhaustive'};

% Define the Structurally Overdetermined set of graphs to examine
SOTypeSet = {'MTES', 'MSO'};

% The brnach selection strategy for BBILP will be Depth-First Search
branchMethod = 'DFS';

for matchIndex = 1:length(matchMethodSet)
    matchMethod = matchMethodSet{matchIndex};
    
    for SOTypeIndex = 1:length(SOTypeSet)
        SOType = SOTypeSet{SOTypeIndex};
        
        % Build the options structure
        SA_settings.matchMethod = matchMethod;
        SA_settings.SOType = SOType;
        SA_settings.branchMethod = branchMethod;
        SA_settings.plotGraphInitial = false;
        SA_settings.plotGraphOver = false;
        SA_settings.plotGraphRemaining = false;
        SA_settings.plotGraphDisconnected = false;
        SA_settings.plotGraphPSO = false;
        SA_settings.plotGraphMatched = false;
        
        % For each model
        for modelIndex=1:length(modelArray)
            
            close all;
            
            %% Read the model description and create the initial graph
            model = modelArray{modelIndex};
            
            %% Perform Structural Analsysis and Matching, extract residual generators
            SA_results = structural_analysis(model, SA_settings);
            
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
            fileName = sprintf('%s_%s_%s.mat',matchMethod, branchMethod,SOType);
            
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


%% Benchmark comparisons between BBILP and exhaustive search
% Plots the comparison results

if strcmp(opMode,'breaking')
    input('Press Enter to proceed to the next step...');
    clc
end

clear
close all 
 
exhaustive_MSO = 'Exhaustive_DFS_MSO'; 
exhaustive_MTES = 'Exhaustive_DFS_MTES'; 
BBILP_MTES = 'BBILP_DFS_MTES'; 
BBILP_MSO = 'BBILP_DFS_MSO'; 
 
files_MTES = {BBILP_MTES, exhaustive_MTES}; 
files_MSO = {BBILP_MSO, exhaustive_MSO }; 
 
x1 = (1:3:(2*length(files_MTES)+1)) + 0.5; 
x2 = x1+1; 
 
load(BBILP_MTES); 
names = {'g008', 'g021','g022','g023','g024','g025','g026'}; 
numExperiments = length(names); 
clear stats 
barWidth = 1/diff(x1(1:2)); 
 
data_MTES = zeros(3,numExperiments); 
data_MSO = data_MTES; 
 
% Load MTES data 
timeSetGen = zeros(length(files_MTES),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(files_MTES) 
    load(files_MTES{i}); 
    for j=1:length(names)
        timeSetGen(i,j) = stats.(names{j}).timeSetGen; 
        timeMakeSG(i,j) = stats.(names{j}).timeMakeSG; 
        timeSolveILP(i,j) = stats.(names{j}).timeSolveILP; 
    end 
    clear stats 
end 
totalTime = timeSetGen + timeSolveILP; 
data_MTES = totalTime; 
 
% Load MSO data 
timeSetGen = zeros(length(files_MSO),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(files_MSO) 
    load(files_MSO{i}); 
    for j=1:length(names)
        timeSetGen(i,j) = stats.(names{j}).timeSetGen; 
        timeMakeSG(i,j) = stats.(names{j}).timeMakeSG; 
        timeSolveILP(i,j) = stats.(names{j}).timeSolveILP; 
    end 
    clear stats 
end 
totalTime = timeSetGen + timeSolveILP; 
data_MSO = totalTime; 
 
fh = figure(); 
 
h1 = barh(x1,data_MTES,'stacked','BarWidth',barWidth); % this should make a stacked bar graph located at the x1 coordinates 
set(gca,'nextplot','add') %add on to the current graph 
h2 = barh(x2,data_MSO,'stacked','BarWidth',barWidth); %this adds another set of bar graphs on the same plot next to it to make two %series with stacked bar graphs 
 
% Set axis properties 
ah = fh.Children; 
ah.YLim = [0 7]; 
ah.XLim = [ah.XLim(1) ah.XLim(2)+2]; 
ah.YTick = 0:7; 
ah.YTickLabel = {'','','BBILP','','','Exhaustive','','',}; 
ah.YLabel.String = 'Matching Method'; 
ah.XLabel.String = 'Cumulative Solution Time (s)'; 
 
% Place explanatory text 
for i=1:length(x1) 
    x_coord = sum(data_MTES(i,:)); 
    text(x_coord+0.1,x1(i),'MTES'); 
end 
for i=1:length(x2) 
    x_coord = sum(data_MSO(i,:)); 
    text(x_coord+0.1,x2(i),'MSO'); 
end 
 
legend({names{:}},'Location','SE'); 
set(ah,'xgrid','on') 
ah.GridColor = [0.2, 0.2, 0.2];  % [R, G, B] 
ah.GridAlpha = 0.9;