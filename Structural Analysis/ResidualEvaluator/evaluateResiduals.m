function [ RE_results ] = evaluateResiduals(SA_results, RG_results, data )
%% EVALUATERESIDUALS Read a log file and play it back onto the residuals

fprintf('Evaluating residual generators\n');

% Get the initial graph interface
gi = SA_results.gi;

time_vector = data.timestamp;
values = RG_results.values;
res_gen_cell = RG_results.res_gen_cell;

residuals = zeros(length(res_gen_cell), length(time_vector));

%% Build the variable ids and aliases

var_aliases = setdiff(fieldnames(data),{'timestamp'});
var_ids = gi.getVarIdByAlias(var_aliases);

%% Iterate over each time instant

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
    
    % Iterate over each residual generator
    for j = 1:length(res_gen_cell)
        res_gen = res_gen_cell{j};
        
        % Check if this residual generator is implemented
        if isempty(res_gen)
            continue;
        end
        
        % Pass the dictionary to each evaluator
        residuals(j,i) = res_gen.evaluate(values);
        
    end
    
end
close(h);

RE_results.residuals = residuals;


end