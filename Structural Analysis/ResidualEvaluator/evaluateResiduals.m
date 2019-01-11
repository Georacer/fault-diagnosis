function [ RE_results ] = evaluateResiduals(SA_results, RG_results, data )
% EVALUATERESIDUALS Read a log file and play it back onto the residuals
% INPUTS:
% SA_results    : Structural Analysis results, as returned by strctural_analysis()
% RG_results    : Residual generation results, as retunred by get_res_gens()
% data          : Resampled, aligned data containing all required variables
% OUTPUTS:
% RE_results    : Residual evaluation results

gi = SA_results.gi; % Get the initial graph interface
time_vector = data.timestamp; % Get the time vector
values = RG_results.values; % Get the variables dictionary
res_gen_cell = RG_results.res_gen_cell; % Get the residual generators set
residuals = zeros(length(res_gen_cell), length(time_vector)); % Initialize the residuals array

%% Zero-out disturbance variables
dist_ids = gi.getVarIdByProperty('isDisturbance');
if ~isempty(dist_ids)
    values.setValue(dist_ids, [], zeros(size(dist_ids)));
end

%% Build the variable ids and aliases

var_aliases = setdiff(fieldnames(data),{'timestamp'});
var_ids = gi.getVarIdByAlias(var_aliases);

%% Iterate over each time sample

h = waitbar(0,'Evaluating log data');
for i=1:length(time_vector)
    waitbar(i/length(time_vector),h);
    t = time_vector(i);
    
    % Build the current sample
    input_value = zeros(1, length(var_ids));
    for j=1:length(var_aliases)
        input_value(j) = data.(var_aliases{j})(i);
    end
    
    % Copy the current input values (each residual generator has its own Dictionary)
    values.setValue(var_ids, var_aliases, input_value)
    
    % Iterate over each realized residual generator
    for j = 1:length(res_gen_cell)
        res_gen = res_gen_cell{j};
        
        % Check if this residual generator is implemented
        if isempty(res_gen)
            continue;
        end
        
        % Pass the dictionary to each evaluator and evaluate
        residuals(j,i) = res_gen.evaluate(values);
        
    end
    
end
close(h);

RE_results.residuals = residuals;


end