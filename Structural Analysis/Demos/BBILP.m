%% testing
% TESTING Utility script to test the various capabilities of the Fault Diagnosis software

% This script involves
% * Generation of the Structural Model
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph
% * Implementation of every residual generator
% * Calculating the numerical Fault Response Vector
% * Calculation of the residuals using a stored log

% close all
clear
clc

%% Setup program execution

% Select the mode of operation
opMode = 'continuous';
opMode = 'breaking';

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

SA_settings.matchMethod = matchMethod;
SA_settings.SOType = SOType;
SA_settings.branchMethod = branchMethod;
SA_settings.plotGraphs = true;

% For each model
for modelIndex=1:length(modelArray)
    
    % Read the model description and create the initial graph
    model = modelArray{modelIndex};
    
    SA_results = structural_analysis(modelArray{modelIndex}, SA_settings);
    
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
    
    fprintf('Faults not covered:\n');
    FSMStruct = generateFSM(SA_results.gi, SA_results.res_gens_set, SA_results.matchings_set);
    SA_results.gi.getExpressionById(SA_results.gi.getEquations(FSMStruct.non_detectable_fault_ids))
    
%     return
    
    %% Do isolability analysis
    IMStruct = generateIM(SA_results.gi, FSMStruct);
    plotIM(IMStruct);
    
    %% Process statistics and save
    %{
    stats = results.stats;
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
    %}
    
    %% Build the residual generators
    
    RG_settings.dt = 1;  % Select the time step, if needed
    
    tic
    RG_results = get_res_gens(SA_results, RG_settings);
    time_generate_residual_generators = toc
    
    %% Find which of the residual generators are dynamic
    
    res_gen_cell = RG_results.res_gen_cell;
    
    dynamic_vector = zeros(1,length(res_gen_cell));
    for i=1:length(dynamic_vector)
        if ~isempty(res_gen_cell{i})
            dynamic_vector(i) = res_gen_cell{i}.is_dynamic;
        else
            dynamic_vector(i) = -1;
        end
    end
    
    % disp(dynamic_vector);
    fprintf('Number of valid res_gens: %g\n', sum(dynamic_vector>=0));
    fprintf('Percentage of valid res_gens: %g\n', sum(dynamic_vector>=0)/length(dynamic_vector));
    fprintf('Percentage of dynamic over valid res_gens: %g\n', sum(dynamic_vector>0)/sum(dynamic_vector>=0));
    
%     return
    
%     clc
    
    %% Calculate the Fault Response Vector of each residual generator
    %{
    fault_response_vector_set = getFaultResponseVector( RG_results.res_gen_cell, [], [] ); % Run all tests, with no pre-calculated fault response vector
    %}
    
    %% Read a log file and play it back onto the residuals
    
    fprintf('Resampling data\n');
    data_resampled = resampleData('afrika.mat', SA_results);  % Read the dataset and resample it to have uniform data
%     data_resampled = resampleData('Arduplane_test.mat', SA_results);  % Read the dataset and resample it to have uniform data
    
    RE_results = evaluateResiduals(SA_results, RG_results, data_resampled);  % Evaluate the residual generator bank
    
    %% Attempt to threshold the residuals
    
%     interval_of_interest = [322:333];
    interval_of_interest = [317:333];
%     interval_of_interest = [1:333];
    
    triggered_residuals = thresholdResiduals(RE_results, interval_of_interest, 0.97);
    FSStruct = generateFSM(SA_results.gi, SA_results.res_gens_set, SA_results.matchings_set);
    
    %% Attempt to isolate the fault
    
    % Attempt to find a single fault
    single_faults = findSingleFault(FSStruct, triggered_residuals);
%     candidate_fault_ids = single_faults;

    % OR
    
    % Exclude faults
    faults_excluded = excludeFaults(FSStruct, triggered_residuals);
    
    % State the rest of the faults    
    candidate_fault_ids = cell(1,length(faults_excluded));    
    candidate_fault_aliases = cell(1,length(faults_excluded));
    
    for i=1:length(candidate_fault_ids)
        candidate_fault_ids{i} = setdiff(FSStruct.fault_ids,faults_excluded{i});
        if isempty(candidate_fault_ids{i})
            continue;
        end
        candidate_fault_aliases{i} = SA_results.gi.getAliasById(candidate_fault_ids{i});
    end
    
    
    % Try to make a nice plot
    plotFaultOccurence(SA_results, candidate_fault_ids, interval_of_interest-1);
    
    %% Analyze residuals
    
    fault_id = SA_results.gi.getVarIdByAlias('fseq43');
%     fault_id = SA_results.gi.getVarIdByAlias('fseq41');
    residual_indices = findRelatedResiduals(SA_results, FSStruct, fault_id);
%     residual_indices = [];
    plotResiduals(RE_results, RG_results, data_resampled.timestamp, residual_indices)
%     plotResiduals(RE_results, RG_results, data_resampled.timestamp, 100:120)
    
end

return