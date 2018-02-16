function [ data_resampled ] = resampleData( fileName, SA_results )
%% resampleDaata Read a log file and generate the required resampled data series
% Intended for the g033 model

%% Read the dataset

dataset_orig = load(fileName);

% Convert it to a more amenable structure

dataset = struct();
messages = fieldnames(dataset_orig);

for i=1:length(messages)
    messageName = messages{i};
    fields = dataset_orig.(messageName).columns;
    for j=1:length(fields)
        fieldName = fields{j};
        dataset.(messageName).(lower(fieldName)) = dataset_orig.(messageName).data(:,j);
    end
end

clear dataset_orig

%% Populate the variables

data = struct();  % Initialize the data container

% Iterate over the dataset
messages = fieldnames(dataset);
for i=1:length(messages)
    messageName = messages{i};
    fields = fieldnames(dataset.(messageName));
    for j=1:length(fields)
        variableName = fields{j};
        variableString = sprintf('%s_%s',lower(variableName), lower(messageName));
        data.(variableString) = dataset.(messageName).(variableName);
    end
end

%% Verify that all model measurement variables exist in the dataset

input_var_ids = SA_results.gi.getVarIdByProperty('isMeasured');
input_var_aliases = SA_results.gi.getAliasById(input_var_ids);

variable_exists = ismember(input_var_aliases,fieldnames(data));
if ~all(variable_exists)
    missing_var_aliases = input_var_aliases(~variable_exists);
    for i=1:length(missing_var_aliases)
        fprintf('Variable %s is not present in the dataset\n',missing_var_aliases{i});
    end
end

%% Decide on a time vector

% Gather all the timestamps
variables = fieldnames(data);
timestamps_mask = startsWith(variables,'timestamp');
timestamps_names = variables(timestamps_mask);
timestamps = cell(1,length(timestamps_names));
for i=1:length(timestamps)
    timestamps{i} = data.(timestamps_names{i});
end

% Find their rates
datarates = zeros(1,length(timestamps));
for i=1:length(datarates)
    datarates(i) = mean(diff(timestamps{i}));
end

bins = 0:0.25:5;
h1 = figure();
hist(datarates, bins);
xlim([0, max(bins)+0.5]);

% 7 telemetry messages come at around 4Hz
% 20 telemetry messages come at around 2Hz
% 1 telemetry message comes at around 0.75Hz
% 3 telemetry messages come at around 1Hz

% We'll go with 1Hz
dt = 1;

% Decide on min/max plot time
% Find the maximum/minimum values for the time domain
t_min = inf;
t_max = -inf;
for i=1:length(timestamps)
    t_min_temp = min(timestamps{i});
    t_max_temp = max(timestamps{i});
    if t_min_temp < t_min
        t_min = t_min_temp;
    end
    if t_max_temp > t_max
        t_max = t_max_temp;
    end
end

% Draw an interval graph to inpspect the timestamp intervals
thickness = 1;
X_arg = zeros(4,length(timestamps));
Y_arg = zeros(4,length(timestamps));
for i=1:length(timestamps)
    t_min_temp = min(timestamps{i})-t_min;
    t_max_temp = max(timestamps{i})-t_min;
    X_arg(1:2,i) = t_min_temp;
    X_arg(3:4,i) = t_max_temp;
    Y_arg([1 4],i) = i;
    Y_arg([2 3],i) = i-thickness;
end

h2 = figure();
patch(X_arg,Y_arg,'b');
xlabel('timestamps (zeroed)');
xlim([0,t_max-t_min])
yticks(linspace(thickness/2, i+thickness/2,i));
yticklabels(timestamps_names);
set(gca,'TickLabelInterpreter','none');

pause();
close(h1);
close(h2);

t_min_user = 2000;
t_max_user = 2332;

% t_min_user = 0;
% t_max_user = t_max-t_min;

time_vector = t_min_user+t_min:dt:t_max_user+t_min;

%% Sample all variables against the selected time vector

% Need to sort among continuous time and discrete data

% Specify which variables you are interested in
input_var_ids = SA_results.gi.getVarIdByProperty('isMeasured');
input_var_aliases = SA_results.gi.getAliasById(input_var_ids);
required_variable_names = input_var_aliases;

available_variables = fieldnames(data);

data_resampled = struct();
data_resampled.timestamp = time_vector;

latest_timestamp = '';
identical_time_instances = [];

for i=1:length(available_variables)
    variable_name = available_variables{i};
    if startsWith(variable_name,'timestamp')
        latest_timestamp = variable_name;
        identical_time_instances = find(diff(data.(latest_timestamp))==0); % Find identical timestamps
        continue;
    end
    
    if ismember(variable_name, required_variable_names)
        time_vector_original = data.(latest_timestamp);
        time_vector_original(identical_time_instances) = []; % Remove identical timestaps
        variable_data = data.(variable_name);
        variable_data(identical_time_instances) = [];
        data_resampled.(variable_name) = interp1(time_vector_original-t_min, variable_data, time_vector-t_min, 'linear', 'extrap'); % Remove the time offset for better data accuracy
    end
end

