% FWUAV_FDI Demonstration of automated FDI on a fixed-wing UAV
% Automated Fault Detection and Identification script on a fixed-wing UAV model, derived from Beard/McLain's Small
% Unmanned Aircraft Book.
% Utilizes simulated flight logs, where an x-axis gyro fault occurs at t=50s.
% Will create a 'residuals' folder, containing csv files with the residual timeseries.

% Execution time: around 5mins, depending on your machine.

% This script involves
% * Generation of the Structural Model
% * Extraction of PSOs for maximum fault isolation
% * Finding valid matchings for each subgraph
% * Implementation of every residual generator
% * Calculation of the residuals using a stored log

close all hidden
clear
clc

%% Setup program execution

% Select the mode of operation
% opMode = 'continuous';
opMode = 'breaking';

% Select the MAVLink model for processing
model = g041(); % Fixed-wing aircraft, modeled after Beard/McLain's Small Unmanned Aircraft Book

% Specify the graph matching method
matchMethod = 'BBILP2';
% matchMethod = 'Exhaustive';
% matchMethod = 'Mixed';

% Specify the desired PSO type
SOType = 'MTES';
% SOType = 'MSO';

% Specify the Brand & Bound ILP branching method
% branchMethod = 'cheap';
branchMethod = 'DFS';
% branchMethod = 'BFS';

% Build the options structure
SA_settings.matchMethod = matchMethod;
SA_settings.SOType = SOType;
SA_settings.branchMethod = branchMethod;
SA_settings.maxMSOsExamined = 0;
SA_settings.exitAtFirstValid = false;
SA_settings.plotGraphInitial = false;
SA_settings.plotGraphOver = false;
SA_settings.plotGraphRemaining = false;
SA_settings.plotGraphDisconnected = false;
SA_settings.plotGraphPSO = false;
SA_settings.plotGraphMatched = true;


%% Perform Structural Analsysis and Matching, extract residual generators
SA_results_orig = structural_analysis(model, SA_settings);

%% Validate matchings
% WARNING Does not apply for graphs with disconnected subgraphs

[valid_pso_array, valid_matching_cell] = validateMatchings(SA_results_orig, SA_settings);
% Delete invalid residuals
SA_results = deleteInvalidMatchings(SA_results_orig, valid_pso_array);
% Display matching statistics
displayMatchingStatistics( SA_results_orig, SA_settings, valid_pso_array, valid_matching_cell );

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
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
title('Ideal Isolability Matrix');

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end

%% Process statistics and save
stats = SA_results.stats;
fileName = sprintf('%s_%s_%s.mat',matchMethod, branchMethod,SOType);

if ~exist(fileName)
    fieldNames = fieldnames(stats);
    for i=1:length(fieldNames)
        stats.(fieldNames{i}).samples = 1;
    end
    save(fileName,'stats');
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
        oldStats.(newFieldName).timeSolveMatching = stats.(newFieldName).timeSolveMatching/recordedSamples + oldStats.(newFieldName).timeSolveMatching*(recordedSamples-1)/recordedSamples;
    else % New graph model
        oldStats.(newFieldName) = stats.(newFieldName);
        oldStats.(newFieldName).samples = 1;
    end
end
stats = oldStats;
save(fileName,'stats');

%% Build the residual generators

RG_settings.dt = 0.01;  % Select the time step, if needed

tic
RG_results = get_res_gens(SA_results, RG_settings);
time_generate_residual_generators = toc

%% Find which of the PSOs actually got an implemented residual generator
% Warning: works only for a single connected subgraph
realizable_matching_mask = zeros(1,length(SA_results.matchings_set{1}));
for i=1:length(realizable_matching_mask)
    if ~isempty(SA_results.matchings_set{1}{i})
        realizable_matching_mask(i) = 1;
    end
end

realizable_residuals_mask = zeros(size(realizable_matching_mask));
for i=1:length(realizable_residuals_mask)
    if ~isempty(RG_results.res_gen_cell{i})
        realizable_residuals_mask(i) = 1;
    end
end

fprintf('Initial realizable matching array: %d elements\n', sum(realizable_matching_mask));
disp(realizable_matching_mask);
fprintf('Actual implemented residuals: %d\n', sum(realizable_residuals_mask));
disp(realizable_residuals_mask);

% Build the fault detection and isolation matrices anew

% Build actual detectablilty matrix
new_res_gens_set = SA_results.res_gens_set{1}(logical(realizable_residuals_mask));
new_matchings_set = SA_results.matchings_set{1}(logical(realizable_residuals_mask));
FSStruct = generateFSM(SA_results.gi, {new_res_gens_set}, {new_matchings_set});

fprintf('Faults not covered:\n');
SA_results.gi.getExpressionById(SA_results.gi.getEquations(FSStruct.non_detectable_fault_ids))

% Build actual isolability matrix
IMStruct = generateIM(SA_results.gi, FSStruct);
plotIM(IMStruct);
title('Actual Isolability Matrix');

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end


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

fprintf('Number of valid res_gens: %g\n', sum(dynamic_vector>=0));
fprintf('Percentage of valid res_gens: %g\n', sum(dynamic_vector>=0)/length(dynamic_vector));
fprintf('Percentage of dynamic over valid res_gens: %g\n', sum(dynamic_vector>0)/sum(dynamic_vector>=0));

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end

%% Read a log file and play it back onto the residuals

% Import data series
state_data = importdata('GraphPool/g041/UAV_recording.bag_states.csv');
state_time_idx = find(strcmp(state_data.colheaders, '%time'));
pm_idx = find(strcmp(state_data.colheaders, 'field.velocity.angular.x'));
qm_idx = find(strcmp(state_data.colheaders, 'field.velocity.angular.y'));
rm_idx = find(strcmp(state_data.colheaders, 'field.velocity.angular.z'));
um_idx = find(strcmp(state_data.colheaders, 'field.velocity.linear.x'));
vm_idx = find(strcmp(state_data.colheaders, 'field.velocity.linear.y'));
wm_idx = find(strcmp(state_data.colheaders, 'field.velocity.linear.z'));
quat_xm_idx = find(strcmp(state_data.colheaders, 'field.pose.orientation.x'));
quat_ym_idx = find(strcmp(state_data.colheaders, 'field.pose.orientation.y'));
quat_zm_idx = find(strcmp(state_data.colheaders, 'field.pose.orientation.z'));
quat_wm_idx = find(strcmp(state_data.colheaders, 'field.pose.orientation.w'));
state_time = state_data.data(:,state_time_idx)/1e9;
pm = state_data.data(:,pm_idx);
qm = state_data.data(:,qm_idx);
rm = state_data.data(:,rm_idx);
um = state_data.data(:,um_idx);
vm = state_data.data(:,vm_idx);
wm = state_data.data(:,wm_idx);
Vam = sqrt(um.^2 + vm.^2 + wm.^2);
quat_xm = state_data.data(:,quat_xm_idx);
quat_ym = state_data.data(:,quat_ym_idx);
quat_zm = state_data.data(:,quat_zm_idx);
quat_wm = state_data.data(:,quat_wm_idx);
eul = quat2eul([quat_wm quat_xm quat_ym quat_zm]);
Phim = (eul(:,3));
Thetam = (eul(:,2));
Psim = unwrap(eul(:,1));

input_data = importdata('GraphPool/g041/UAV_recording.bag_inputs.csv');
input_time_idx = find(strcmp(input_data.colheaders, '%time'));
dac_idx = find(strcmp(input_data.colheaders, 'field.value0'));
dec_idx = find(strcmp(input_data.colheaders, 'field.value1'));
dtc_idx = find(strcmp(input_data.colheaders, 'field.value2'));
drc_idx = find(strcmp(input_data.colheaders, 'field.value3'));
input_time = input_data.data(:,input_time_idx)/1e9;
dac = (input_data.data(:,dac_idx)-1500)/500*0.3491; % in rad
dec = (input_data.data(:,dec_idx)-1500)/500*0.3491;
dtc = (input_data.data(:,dtc_idx)-1000)/1000;
drc = (input_data.data(:,drc_idx)-1500)/500*0.3491;

% Delete duplicate points
dupe_input_idx = find(diff(input_time)==0);
input_time(dupe_input_idx) = [];
dac(dupe_input_idx) = [];
dec(dupe_input_idx) = [];
dtc(dupe_input_idx) = [];
drc(dupe_input_idx) = [];

% Calculate resampled time vector
state_time_fixed = linspace(min(state_time), max(state_time), length(state_time)); % Build a new state_time because the system timestamp is often repeating

tstart = 40;
tend = 60;
tfault = 55;
dt = 0.01;
time_vec = tstart:dt:tend;

% Resample data
data_resampled.timestamp = time_vec;
data_resampled.dac = interp1(input_time, dac, time_vec, 'previous');
data_resampled.dec = interp1(input_time, dec, time_vec, 'previous');
data_resampled.dtc = interp1(input_time, dtc, time_vec, 'previous');
data_resampled.drc = interp1(input_time, drc, time_vec, 'previous');
data_resampled.Vam = interp1(state_time_fixed, Vam, time_vec, 'linear');
data_resampled.pm = interp1(state_time_fixed, pm, time_vec, 'linear');
data_resampled.qm = interp1(state_time_fixed, qm, time_vec, 'linear');
data_resampled.rm = interp1(state_time_fixed, rm, time_vec, 'linear');
data_resampled.Phim = interp1(state_time_fixed, Phim, time_vec, 'linear');
data_resampled.Thetam = interp1(state_time_fixed, Thetam, time_vec, 'linear');
data_resampled.Psim = interp1(state_time_fixed, Psim, time_vec, 'linear');

% Construct freezing roll gyro fault
fault_Vam = zeros(size(time_vec));
fault_tstart = tfault;
fault_idxstart = find(time_vec>=fault_tstart,1,'first');
fault_tend = tend;
fault_idxend = find(time_vec<fault_tend,1,'last');
fault_max = data_resampled.pm(fault_idxstart);
fault_idx = fault_idxstart:1:fault_idxend;
data_resampled.pm(fault_idx) = fault_max;

% Initialize values dictionary
names = setdiff(fieldnames(data_resampled), 'timestamp');
for i=1:length(names)
    name = names{i};
    RG_results.values.setValue([], {name(1:end-1)}, data_resampled.(name)(1));
end
% Initialize residual generators
for i=1:length(RG_results.res_gen_cell)
    rg = RG_results.res_gen_cell{i};
    if ~isempty(rg)
        rg.reset_state(RG_results.values);
    end
end

% Evaluate the residuals
RE_results = evaluateResiduals(SA_results, RG_results, data_resampled);  % Evaluate the residual generator bank

%% Plot the residuals

residual_indices = find(realizable_residuals_mask); % Select which residuals to plot
fault_alias = 'fseq6'; % Select fault, to highlight affected residuals
t_start = tstart +10; % Allow some time for residuals to settle
t_end = tend;
t_fault = tfault; % Set fault occurrence time, for plotting its onset

plotResiduals2( residual_indices, t_start, t_end, t_fault, SA_results, RG_results, RE_results, fault_alias);

%% Write-out the results

time_vector = RE_results.time_vector;
plot_idxstart = find(time_vector>=t_start, 1, 'first');
plot_idxend = find(time_vector<t_end, 1, 'last');

mkdir('residuals');
for i = residual_indices
    filename = sprintf('residuals/res%d.csv',i);
    dlmwrite(filename, [RE_results.time_vector(plot_idxstart:plot_idxend)' RE_results.residuals(i,plot_idxstart:plot_idxend)']);
end

return