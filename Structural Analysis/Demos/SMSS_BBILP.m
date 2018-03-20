%% SMSS-BBILP
% SMSS-BBILP-FRVk - Script showcasing the Branch and Bound Binary ILP and the Fault Response Vector methodoogies, as
% presented in Systems, Man and Cybernetics: Systems journal
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% March 2018; Last revision: -

% This demo script involves: FIXME
% * Generation of the Structural Model
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph
% * Implementation of every residual generator
% * Calculation of the residuals using a stored log

% INSTRUCTIONS:


close all
clear
clc

%% Setup program execution

% Select the mode of operation
opMode = 'continuous';
% opMode = 'breaking';

% Select the MAVLink model for processing
modelArray = {};

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

modelArray{end+1} = g008();
modelArray{end+1} = g021();
modelArray{end+1} = g022();
modelArray{end+1} = g023();
modelArray{end+1} = g024();
modelArray{end+1} = g025();
modelArray{end+1} = g026();

% modelArray{end+1} = g014g();
% modelArray{end+1} = g005a();

% matchMethod = 'BBILP';
% matchMethod = 'Exhaustive';

SOType = 'MTES';
% SOType = 'MSO';

% branchMethod = 'cheap';
branchMethod = 'DFS';
% branchMethod = 'BFS';

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
    counter = 0;
    for i=1:length(SA_results.matchings_set)
        for j=1:length(SA_results.matchings_set{i})
            if ~isempty(SA_results.matchings_set{i}(j))
                counter = counter + 1;
            end
        end
    end
    
    fprintf('Total number of valid residuals found: %d\n',counter);

    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    %% Do detectability analysis
    
    % Create the Fault Signature Matrix and related information
    FSStruct = generateFSM(SA_results.gi, SA_results.res_gens_set, SA_results.matchings_set);
    
    fprintf('Faults not covered:\n');
    SA_results.gi.getExpressionById(SA_results.gi.getEquations(FSStruct.non_detectable_fault_ids))
    
    %% Do isolability analysis
    
    % Create the Isolation Matrix and related information
    IMStruct = generateIM(SA_results.gi, FSStruct);
    plotIM(IMStruct);
    
    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
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

return