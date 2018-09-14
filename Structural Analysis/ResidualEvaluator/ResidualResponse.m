classdef ResidualResponse < handle
    %RESIDUALSENSITIVITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gi
        res_gen
        arg_ids
        values = Dictionary.empty;
        fault_ids
        disturbance_ids
        fault_id_current
        input_ids
        var_ids
        pso_input_ids
        opt_variables
        inner_problem_optim_values
        best_minimum_response_cost
        step_counter = 0;
        timeDetection
        dt
        
        inner_problem_method;
        
        plotCost
        plotSwarm
        plotSwarmIds
        testMask  % Which faults to examine for
        
        debug = true;
        %         debug = false;
    end
    
    methods
        function [ obj ] = ResidualResponse( varargin )
            % Constructor
            
            p = inputParser;
            
            p.addRequired('res_gen',@(x) isa(x, 'ResidualGenerator'));
            p.addRequired('arg_ids',@isnumeric); % The variable IDs for maximization
%             p.addParameter('testType', 'fault', @(s) validatestring(s, {'fault', 'disturbance'})); % Unneeded, will
%             sort out through IDs
            p.addParameter('timeDetection', 0 ,@isnumeric); % Probably will deprecate
            p.addParameter('deltat', 0.01 ,@isnumeric);
            p.addParameter('innerProblem', 'fminbound' ,@(s) ismember(s, {'fminbound', 'pso'}));
            p.addParameter('plotCost', false , @islogical);
            p.addParameter('plotSwarm', false, @islogical);
            p.addParameter('plotSwarmIds', [], @isnumeric);  % Array of 1 or 2 ids which will be plotted through plotSwarm
            p.addParameter('testMask', 0, @isnumeric); % Probably unneeded, arg_ids has the same effect
            
            p.parse(varargin{:});
            opts = p.Results;
            obj.res_gen = opts.res_gen;
            obj.gi = opts.res_gen.gi;
            
            obj.arg_ids = opts.arg_ids;
            
%             obj.testType = opts.testType;
            obj.timeDetection = opts.timeDetection;
            obj.dt = opts.deltat;
            obj.plotCost = opts.plotCost;
            obj.plotSwarm = opts.plotSwarm;
            obj.plotSwarmIds = opts.plotSwarmIds;
            
            % Set the inner problem method
            obj.inner_problem_method = opts.innerProblem;
            
            % Sanitize arg_ids
            % Check if they are part of res_gen
            if ~all(ismember(obj.arg_ids, obj.res_gen.all_input_ids))
                error('Not all passed argument IDs are input variables of the residual generator');
            end
            if ~all(obj.gi.isFault(obj.arg_ids) | obj.gi.isDisturbance(obj.arg_ids))
                error('Currently only fault and disturbance optimization is supported')
            end
            
            % Get a new dictionary
            obj.values = copy(obj.res_gen.values);
            
            % Get variable input ids for the whole residual generator
%             var_ids = obj.res_gen.get_input_ids();
            obj.var_ids = obj.res_gen.all_input_ids; % Contains inputs, faults, disturbances and measurements
            
            % Separate the inputs from the faults
            fault_mask = obj.gi.isOfProperty(obj.var_ids, 'isFault');
            input_mask = obj.gi.isOfProperty(obj.var_ids, 'isInput');
            disturbance_mask = obj.gi.isOfProperty(obj.var_ids, 'isDisturbance');
            measured_mask = obj.gi.isOfProperty(obj.var_ids, 'isMeasured');
            obj.fault_ids = obj.var_ids(fault_mask);
            obj.disturbance_ids = obj.var_ids(disturbance_mask);
            obj.input_ids = obj.var_ids( (input_mask | measured_mask) & ~fault_mask & ~disturbance_mask); % These are actual user inputs
            
%             if isempty(opts.testMask)
%                 obj.testMask = ones(2,length(obj.fault_ids));
%             else
%                 obj.testMask = opts.testMask;
%             end
            
        end
        
        function [ cost ] = fitness_function_maximum(obj, sampled_values)
            % Objective function for maximum fault impact PSO
            % sampled_values: sampled values of variables under optimization
            obj.values.setValue(obj.opt_variables, [], sampled_values);
            
            obj.res_gen.reset_state();  % Reset the state variables %TODO: is this correct?
            cost_initial = obj.residual_evaluation_cost(obj.values);
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            cost_penalty = obj.constraint_cost(sampled_values);    % pso_input_vec has the fault at its last position
            cost = cost_initial + cost_penalty;
            
            if obj.plotSwarm
                plotSwarm(obj.plotSwarmIds,cost_initial,'iter');
            end
        end
        
        function [ cost ] = fitness_function_minimum_inner(obj, input_values, arg_values)
            % Objective function for maximum fault impact PSO
            % input_values: The sampled values of the known variables of the residual generator
            % arg_values: the sampled values of the fault/disturbances under optimization
            
            % Set the exterior input variable values
            obj.values.setValue(obj.input_ids, [], input_values);
            
            obj.res_gen.reset_state();  % Reset the state variables %TODO: is this correct?
            cost_initial = -obj.residual_evaluation_cost(obj.values);
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            cost_penalty = obj.constraint_cost([input_values arg_values]);
            cost = cost_initial + cost_penalty;
        end
        
        function [ cost ] = residual_evaluation_cost(obj, values)
            % Residual evaluation cost to be minimized
            
            % Zero-out faults and disturbances
            values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
            values.setValue(obj.disturbance_ids, [], zeros(size(obj.disturbance_ids)));
            
            % Check if integration is needed
            if obj.res_gen.is_dynamic
                if obj.timeDetection > 0 % A horizon has been set %TODO: This should be replaced with steady-state conditions
                    % Step once to populate res_gen values
                    obj.res_gen.evaluate(values);
                    % Calculate the required number of iterations
                    iterations = floor(obj.timeDetection/obj.dt) - 2;
                    % Run the integration
                    for i=1:iterations
                        obj.res_gen.evaluate(obj.res_gen.values);
                    end
                    % Run the last iteration to graph the residual value
                    cost = -abs(obj.res_gen.evaluate(obj.res_gen.values));
                else
                    cost = -abs(obj.res_gen.evaluate(values));
                end
            else
                cost = -abs(obj.res_gen.evaluate(values));
            end
        end
        
        function [ cost ] = fitness_function_minimum(obj, arg_values)
            % Objective function for minimum fault impact PSO
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question in the last element
            obj.values.setValue(obj.arg_ids, [], arg_values);
            
            if obj.plotCost
                PlotFcn = @pswplotbestf;
            else
                PlotFcn = [];
            end

            % Setup the problem for particleswarm
            
            limits = obj.gi.getLimits(obj.input_ids);
            lower_bounds = limits(:,1);
            upper_bounds = limits(:,2);

            display_type = 'off';
            particleswarm_options = optimoptions('particleswarm',...
                'SwarmSize', 30, ...
                'Display',display_type, ...
                'MaxIterations',200, ...
                'MaxStallIterations', 10, ...
                'OutputFcn', @obj.update_steps, ...
                'PlotFcn', PlotFcn ...
                );
            problem.solver = 'particleswarm';
            problem.objective = @(input_values) obj.fitness_function_minimum_inner(input_values, arg_values);
            problem.nvars = length(obj.input_ids);
            problem.lb = lower_bounds;
            problem.ub = upper_bounds;
            problem.options = particleswarm_options;

            % Run the PSO
            [input_optim_values, inner_cost] = particleswarm(problem);
%%             
%             %% Maximum fault response search using Particle Swarm
%             if strcmp(obj.inner_problem_method, 'pso')
%                 
%                 % Setup the inner optimization problem
%                 % Build the input bounds
%                 limits = obj.gi.getLimits(obj.ard_ids);
%                 lower_bounds = limits(:,1);
%                 upper_bounds = limits(:,1);
%                 % Setup the problem for particleswarm
%                 display_type = 'off';
%                 %             display_type = 'iter';
%                 particleswarm_options = optimoptions('particleswarm',...
%                     'SwarmSize', min(10*length(obj.arg_ids), 30), ...
%                     'Display',display_type, ...
%                     'MaxIterations',100, ...
%                     'MaxStallIterations', 5 ...
%                     );
%                 problem.solver = 'particleswarm';
%                 problem.objective = @(arg_values) obj.fitness_function_minimum_inner(input_values, arg_values);
%                 problem.nvars = length(obj.arg_ids);
%                 problem.lb = lower_bounds;
%                 problem.ub = upper_bounds;
%                 problem.options = particleswarm_options;
%                 % Run the PSO to find the fault value which maximizes the fault
%                 % impact
%                 obj.res_gen.reset_state();  % Reset the state variables
%                 [optim_values, inner_cost] = particleswarm(problem);
%                 
%                 %% Maximum fault response search using fminbound
%             elseif strcmp(obj.inner_problem_method, 'fminbound')
%                 
%                 % Verify input
%                 if length(obj.arg_ids)>1
%                     error('fminbound cannot optimize more than 1 variable');
%                 end
%                 
%                 % Build the input bounds
%                 limits = obj.gi.getLimits(obj.arg_ids);
%                 lower_bound = limits(1);
%                 upper_bound = limits(2);
%                 
%                 display_type = 'off';
%                 %             display_type = 'iter';
%                 fminbnd_options = optimset(...
%                     'Display',display_type ...
%                     );
%                 problem.solver = 'fminbnd';
%                 problem.objective = @(f) obj.fitness_function_minimum_inner(input_values, f);
%                 problem.x1 = lower_bound;
%                 problem.x2 = upper_bound;
%                 problem.options = fminbnd_options;
%                 % Run the SINGLE-variable solver
%                 [ optim_values, inner_cost] = fminbnd(problem);
%                 
%             else
%                 error('Unsupported maximization method');
%             end
            
            %%
            
            % Evaluate the residual response for the given state and the
            % returned inner values
%             obj.values.setValue(obj.input_ids, [], input_values);
%             obj.values.setValue(obj.arg_ids, [], zeros(size(obj.arg_ids)));
%             cost_initial = abs(obj.res_gen.evaluate(obj.values));
            cost_initial = inner_cost;
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            cost_penalty = obj.constraint_cost([input_optim_values arg_values]);    % pso_input_vec has the fault at its last position
            cost = cost_initial + cost_penalty;
            
            % If this particle has the best response, then store its fault
            % value
            if cost < obj.best_minimum_response_cost
                obj.inner_problem_optim_values = input_optim_values;
                obj.best_minimum_response_cost = cost;
            end
        end
        
        function [ penalty ] = constraint_cost(obj, sampled_values)
            % Calculate cost induced by constraints
            [~, error_eq] = obj.constraints(sampled_values);
            
            % Set q
            q = max(0, abs(error_eq)); %TODO unneeded?
            
            % Set theta
            if q < 0.001
                theta = 10;
            elseif q < 0.1
                theta = 20;
            elseif q < 1
                theta = 100;
            else
                theta = 300;
            end
            
            % Set gamma
            %             if q < 1
            if q < 0.1
                gamma = 1;
            else
                gamma = 2;
            end
            
            %             k = obj.step_counter; % Adaptive penalty cannot work with
            %             this implementation, because particleswarm() does not update
            %             its best fit value on each iteration: The old, cheaper
            %             position fix persists.
            k=1;
            
            penalty = sqrt(k) * theta*q^gamma;
        end
        
        function [inequality, equality] = constraints(obj, sampled_values)
            % General nonlinear constraints for the optimization problem
            % sample_values: indexed vector holding the current values of the sampled values of optimization variables
            inequality = []; % No inequality terms
            
            obj.values.setValue(obj.opt_variables, [], sampled_values); % Set the values of the input
            
            obj.res_gen.reset_state(); %TODO: is this correct?
            equality = obj.res_gen.evaluate(obj.values);
            if isinf(equality)
                error('Equality constraint error is not expected to be inf');
            end
        end
        
        function [ stop ] = update_steps(obj, optimValues, state)
            % Auxiliary function to count the particle swarm algorithm
            % steps
            obj.step_counter = optimValues.iteration;
            
            stop = false;
        end
        
        function [ max_response] = get_max_response(obj)
            
            obj.opt_variables = [obj.input_ids obj.arg_ids]; % The optimization parameters: system variables + fault/disturbance variables
            
            % Build the input bounds
            limits = obj.gi.getLimits(obj.opt_variables);
            lower_bounds = limits(:,1);
            upper_bounds = limits(:,2);

            if obj.plotCost
                PlotFcn = @pswplotbestf;
            else
                PlotFcn = [];
            end

            % Setup the problem for particleswarm
            if obj.debug
                display_type = 'iter';
            else
                display_type = 'off';
            end
            if obj.plotSwarm
                plotSwarm([0 0],0,'init');
            end
            particleswarm_options = optimoptions('particleswarm',...
                'SwarmSize',300, ...
                'Display',display_type, ...
                'MaxIterations',200, ...
                'MaxStallIterations', 10, ...
                'OutputFcn', @obj.update_steps, ...
                'PlotFcn', PlotFcn ...
                );
            problem.solver = 'particleswarm';
            problem.objective = @obj.fitness_function_maximum;
            problem.nvars = length(obj.opt_variables);
            problem.lb = lower_bounds;
            problem.ub = upper_bounds;
            problem.options = particleswarm_options;
            % Run the PSO
            [optim_values, response] = particleswarm(problem);

            obj.values.setValue(obj.opt_variables, [], optim_values);
            obj.res_gen.reset_state();  % Reset the state variables %TODO: is this correct? Doesn't stor _prev values
            obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
            obj.values.setValue(obj.disturbance_ids, [], zeros(size(obj.disturbance_ids)));
            max_response = abs(obj.res_gen.evaluate(obj.values)); %TODO: warning, does not take state into account

            if obj.debug
                print_optim_results(obj, 'Maximum', optim_values, max_response);
            end
        end
        
        function [ min_response ] = get_min_response(obj)           
            % Calculate the minimum fault contributions  
            
            if length(obj.arg_ids)>1 && strcmp(obj.inner_problem_method, 'fminbound')
                error('fminbound cannot handle multi-variable optimization');
            end
            
            obj.opt_variables = [obj.input_ids obj.arg_ids]; % The optimization parameters: system variables + fault/disturbance variables

            limits = obj.gi.getLimits(obj.arg_ids);
            lower_bounds = limits(:,1);
            upper_bounds = limits(:,2);
            
            % Values needed for the inner maximization
            obj.inner_problem_optim_values = nan;
            obj.best_minimum_response_cost = inf;
            
            if obj.debug
                display_type = 'iter';
            else
                display_type = 'off';
            end
                
            if strcmp(obj.inner_problem_method, 'pso')

                % Setup the problem for particleswarm
                particleswarm_options = optimoptions('particleswarm',...
                    'SwarmSize', min(10*length(obj.arg_ids), 30), ...
                    'Display',display_type, ...
                    'MaxIterations',100, ...
                    'MaxStallIterations', 5 ...
                    );
                problem.solver = 'particleswarm';
                problem.objective = @(arg_values) obj.fitness_function_minimum(arg_values);
                problem.nvars = length(obj.arg_ids);
                problem.lb = lower_bounds;
                problem.ub = upper_bounds;
                problem.options = particleswarm_options;
                % Run the PSO to find the fault value which maximizes the fault
                % impact
                obj.res_gen.reset_state();  % Reset the state variables
                [arg_optim_values, inner_cost] = particleswarm(problem);

            % Maximum fault response search using fminbound
            elseif strcmp(obj.inner_problem_method, 'fminbound')

                % Verify input
                if length(obj.arg_ids)>1
                    error('fminbound cannot optimize more than 1 variable');
                end
                fminbnd_options = optimset(...
                    'Display',display_type ...
                    );
                problem.solver = 'fminbnd';
                problem.objective = @(arg_values) obj.fitness_function_minimum(arg_values);
                problem.x1 = lower_bounds;
                problem.x2 = upper_bounds;
                problem.options = fminbnd_options;
                % Run the SINGLE-variable solver
                [arg_optim_values, inner_cost] = fminbnd(problem);
            else
                error('Unsupported maximization method');
            end

            % Add the discovered fault value
            optim_values = [obj.inner_problem_optim_values arg_optim_values];
            obj.values.setValue(obj.opt_variables, [], optim_values);
            obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
            obj.values.setValue(obj.disturbance_ids, [], zeros(size(obj.disturbance_ids)));
            obj.res_gen.reset_state();  % Reset the state variables
            min_response = abs(obj.res_gen.evaluate(obj.values));

            if obj.debug
                print_optim_results(obj, 'Minimum', optim_values, min_response);
            end
            
        end
        
        function print_optim_results(obj, optim_type, optim_values, response)
            fprintf('%s Residual Response: Solution found at:\n', optim_type);
            for j=1:length(obj.opt_variables)
                alias = obj.gi.getAliasById(obj.opt_variables(j));
                fprintf('%5s = %f;\n', alias{1}, optim_values(j));
            end

            fprintf('with response: %g\n\n', response);

            obj.values.setValue(obj.opt_variables, [], optim_values);
            obj.res_gen.reset_state();
            obj.res_gen.evaluate(obj.values);
            fprintf('Residual consistency: %g\n', obj.res_gen.evaluate(obj.values));
            disp(obj.res_gen.values);

            obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
            obj.values.setValue(obj.disturbance_ids, [], zeros(size(obj.disturbance_ids)));
            obj.res_gen.reset_state();
            obj.res_gen.evaluate(obj.values);
            fprintf('Residual generator state: \n')
            disp(obj.res_gen.values);
        end
        
         % DELETEME
        function [ fault_contribution ] = get_residual_sensitivity(obj)
            
            % Initialize the fault response vectors
            fault_contribution_maximum = zeros(size(obj.fault_ids));
            fault_contribution_minimum = inf*ones(size(fault_contribution_maximum));
            
            
            % Iterate over all faults
            for i=1:size(obj.testMask,2)
                tic;
                
                if obj.testMask(2,i)
                    %% Calculate the maximum fault contributions
                    % Reset fault values
                    obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids))); %TODO: needed?
                    
                    % Pick one fault and build the input array
                    fault_index = i;
                    obj.fault_id_current = obj.fault_ids(fault_index);
                    obj.pso_input_ids = [obj.input_ids obj.fault_id_current];
                    
                    % Build the input bounds
                    limits = obj.gi.getLimits(obj.pso_input_ids);
                    lower_bounds = limits(:,1);
                    upper_bounds = limits(:,2);
                    
                    if obj.plotCost
                        PlotFcn = @pswplotbestf;
                    else
                        PlotFcn = [];
                    end
                    
                    % Setup the problem for particleswarm
                    if obj.debug
                        display_type = 'iter';
                    else
                        display_type = 'off';
                    end
                    if obj.plotSwarm
                        plotSwarm([0 0],0,'init');
                    end
                    particleswarm_options = optimoptions('particleswarm',...
                        'SwarmSize',300, ...
                        'Display',display_type, ...
                        'MaxIterations',200, ...
                        'MaxStallIterations', 10, ...
                        'OutputFcn', @obj.update_steps, ...
                        'PlotFcn', PlotFcn ...
                        );
                    problem.solver = 'particleswarm';
                    problem.objective = @obj.fitness_function_maximum;
                    problem.nvars = length(obj.pso_input_ids);
                    problem.lb = lower_bounds;
                    problem.ub = upper_bounds;
                    problem.options = particleswarm_options;
                    % Run the PSO
                    [args, sensitivity] = particleswarm(problem);
                    
                    obj.values.setValue(obj.pso_input_ids, [], args);
                    obj.res_gen.reset_state();  % Reset the state variables
                    fault_contribution_maximum(i) = abs(obj.res_gen.evaluate(obj.values));
                    
                    if obj.debug
                        fprintf('Maximum Residual Sensitivity: Solution found at:\n');
                        for j=1:length(args)
                            alias = obj.gi.getAliasById(obj.pso_input_ids(j));
                            fprintf('%5s = %f;\n', alias{1}, args(j));
                        end
                        
                        fprintf('with response: %g\n', fault_contribution_maximum(i));
                        
                        obj.values.setValue(obj.pso_input_ids, [], args);
                        obj.res_gen.reset_state();
                        obj.res_gen.evaluate(obj.values);
                        %                     disp(obj.values);
                        fprintf('Residual generator state: \n')
                        disp(obj.res_gen.values);
                        
                        obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
                        obj.res_gen.reset_state();
                        fprintf('Residual consistency: %g\n', obj.res_gen.evaluate(obj.values));
                        disp(obj.res_gen.values);
                    end
                end
                
                if obj.testMask(1,i)
                    %% Calculate the minimum fault contributions
                    
                    obj.inner_problem_fault_values = nan;
                    obj.best_minimum_response_cost = inf;
                    
                    % Pick one fault and build the input array
                    fault_index = i;
                    obj.fault_id_current = obj.fault_ids(fault_index);
                    obj.pso_input_ids = [obj.input_ids obj.fault_id_current];
                    
                    % Build the input bounds
                    limits = obj.gi.getLimits(obj.input_ids);
                    lower_bounds = limits(:,1);
                    upper_bounds = limits(:,2);
                    
                    if obj.plotCost
                        PlotFcn = @pswplotbestf;
                    else
                        PlotFcn = [];
                    end
                    
                    % Setup the problem for particleswarm
                    if obj.debug
                        display_type = 'iter';
                    else
                        display_type = 'off';
                    end
                    
                    particleswarm_options = optimoptions('particleswarm',...
                        'SwarmSize',30, ...
                        'Display',display_type, ...
                        'MaxIterations',200, ...
                        'MaxStallIterations', 10, ...
                        'OutputFcn', @obj.update_steps, ...
                        'PlotFcn', PlotFcn ...
                        );
                    problem.solver = 'particleswarm';
                    problem.objective = @obj.fitness_function_minimum;
                    problem.nvars = length(obj.input_ids);
                    problem.lb = lower_bounds;
                    problem.ub = upper_bounds;
                    problem.options = particleswarm_options;
                    
                    % Run the PSO
                    [args, sensitivity] = particleswarm(problem);
                    
                    % Add the discovered fault value
                    args = [args obj.inner_problem_fault_values];
                    obj.values.setValue(obj.pso_input_ids, [], args);
                    obj.res_gen.reset_state();  % Reset the state variables
                    fault_contribution_minimum(i) = abs(obj.res_gen.evaluate(obj.values));
                    
                    if obj.debug
                        fprintf('Minimum Residual Sensitivity: Solution found at:\n');
                        for j=1:length(args)
                            alias = obj.gi.getAliasById(obj.pso_input_ids(j));
                            fprintf('%5s = %f;\n', alias{1}, args(j));
                        end
                        
                        fprintf('with response: %g\n', fault_contribution_minimum(i));
                        
                        obj.values.setValue(obj.pso_input_ids, [], args);
                        obj.res_gen.reset_state();
                        obj.res_gen.evaluate(obj.values);
                        %                     disp(obj.values);
                        fprintf('Residual generator state: \n')
                        disp(obj.res_gen.values);
                        
                        obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
                        obj.res_gen.reset_state();
                        fprintf('Residual consistency: %g\n', obj.res_gen.evaluate(obj.values));
                        disp(obj.res_gen.values);
                    end
                    
                    
                    toc
                    %                 pause();
                end
                
                
                fault_contribution = [fault_contribution_minimum; fault_contribution_maximum];
                
            end
            
        end
        
    end
    
end

