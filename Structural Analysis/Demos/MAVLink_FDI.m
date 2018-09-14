%% IROS2018_MAVLink
% IROS2018_MAVLink - Script performing all the graph processing and calculations for the IROS2018 submission, involving an
% ArduPlane MAVLink log model.
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% March 2018; Last revision: -

% This demo script involves
% * Generation of the Structural Model
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph
% * Implementation of every residual generator
% * Calculation of the residuals using a stored log

close all
clear
clc

% Select the mode of operation
% opMode = 'continuous';
opMode = 'breaking';

% Select the MAVLink model for processing
modelArray = {};
modelArray{end+1} = g033();

% Specify the graph matching method
matchMethod = 'BBILP';

% Specify the desired PSO type
SOType = 'MTES';

% Specify the Brand & Bound ILP branching method
branchMethod = 'DFS';

% Build the options structure
SA_settings.matchMethod = matchMethod;
SA_settings.SOType = SOType;
SA_settings.branchMethod = branchMethod;
SA_settings.plotGraphInitial = true;
SA_settings.plotGraphOver = true;
SA_settings.plotGraphRemaining = true;
SA_settings.plotGraphDisconnected = true;
SA_settings.plotGraphPSO = true;
SA_settings.plotGraphMatched = true;

%% For each model in modelArray (Only 1 loop for this particular example)
for modelIndex=1:length(modelArray)
    
    %% Structural graph generation
    % Read the model description and create the initial MAVLink graph
    model = modelArray{modelIndex};
    
    % Perform Structural Analsysis and Matching, extract residual generators
    SA_results = structural_analysis(modelArray{modelIndex}, SA_settings);
    
    % Inspection: Display the total number of residual generators found
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
    
    %% Cross back to the Analytical Domain: Build the residual generators
    
    RG_settings.dt = 1;  % Select the time step used for dynamic residuals, if needed
    
    tic
    RG_results = get_res_gens(SA_results, RG_settings);
    time_generate_residual_generators = toc
    
    %% Inspection: Find which of the residual generators are dynamic
    
    res_gen_cell = RG_results.res_gen_cell;
    
    dynamic_vector = zeros(1,length(res_gen_cell));
    for i=1:length(dynamic_vector)
        if ~isempty(res_gen_cell{i})
            dynamic_vector(i) = res_gen_cell{i}.is_dynamic;
        else
            dynamic_vector(i) = -1;
        end
    end
    
    fprintf('Number of valid res_gens: %g\n', sum(dynamic_vector>=0));
    fprintf('Percentage of valid res_gens: %g\n', sum(dynamic_vector>=0)/length(dynamic_vector));
    fprintf('Percentage of dynamic over valid res_gens: %g\n', sum(dynamic_vector>0)/sum(dynamic_vector>=0));
    
    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    %% Read a log file and play it back onto the residuals
    
    fprintf('Resampling data\n');
    data_resampled = resampleData('afrika.mat', SA_results);  % Read the dataset and resample it to have uniform data
    
    RE_results = evaluateResiduals(SA_results, RG_results, data_resampled);  % Evaluate the residual generator bank
    
    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    %% Treshold the residuals
    
    interval_of_interest = [317:333]; % Select the sample interval you wish to investigate
    
    triggering_threshold = 0.97; % Specify a static threshold
%     triggering_threshold = 0.975; % Specify a static threshold
    
    % Threshold the residual signals
    triggered_residuals = thresholdResiduals(RE_results, interval_of_interest, triggering_threshold);
    
    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    %% Attempt to isolate occurring faults
    
%     % For each time sample, try to find if a single fault explains the fault signature
%     single_faults = findSingleFault(FSMStruct, triggered_residuals);
%     candidate_fault_ids = single_faults;
    
    % For each time sample, exclude any fault whose fault signature isn't present in the triggered residuals
    faults_excluded = excludeFaults(FSStruct, triggered_residuals);
    % Collect the rest of the faults    
    candidate_fault_ids = cell(1,length(faults_excluded));    
    candidate_fault_aliases = cell(1,length(faults_excluded));
    % Subtract excluded faults from the candidate faults sets
    for i=1:length(candidate_fault_ids)
        candidate_fault_ids{i} = setdiff(FSStruct.fault_ids,faults_excluded{i});
        if isempty(candidate_fault_ids{i})
            continue;
        end
        candidate_fault_aliases{i} = SA_results.gi.getAliasById(candidate_fault_ids{i});
    end
    
    % Plot the Fault Occurrence Grid
    fig_handle = plotFaultOccurence(SA_results, candidate_fault_ids, interval_of_interest-1);
    
    % Add fault event line
    line(fig_handle.Children(1), 'XData', [322 322], 'YData', [0, 50], 'Color', 'red', 'LineStyle', '--'); 
    text(322.5, 33, 'Failure Event', 'Color', 'red');
    ylabel('Candidate Fault in Message ID/Field')
    
    if strcmp(opMode,'breaking')
        input('Press Enter to proceed to the next step...');
        clc
    end
    
    %% Visualize residuals
    
    fault_id = SA_results.gi.getVarIdByAlias('fseq43'); % Select a fault
%     fault_id = SA_results.gi.getVarIdByAlias('fseq41');

    % Find all the residuals which are sensitive to it
    residual_indices = findRelatedResiduals(SA_results, FSStruct, fault_id);
%     residual_indices = [];

    % Plot them
    plotResiduals(RE_results, RG_results, data_resampled.timestamp, residual_indices)
    
end

return