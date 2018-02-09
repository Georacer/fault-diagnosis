classdef ResidualSensitivity < handle
    %RESIDUALSENSITIVITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gi
        res_gen
        values = Dictionary.empty;
        fault_ids
        fault_id_current
        input_ids
        pso_input_ids
        inner_problem_fault_value
        best_minimum_response_cost
        step_counter = 0;
        timeDetection
        dt
        
        inner_problem_method;
        
        plotCost
        plotSwarm
        plotSwarmIds
        faultIndex  % Which faults to examine for
        testMin
        testMax
        
        debug = true;
%         debug = false;
    end
    
    methods
        function [ obj ] = ResidualSensitivity( varargin )
            % Constructor
            
            p = inputParser;
            
            p.addRequired('res_gen',@(x) isa(x, 'ResidualGenerator'));
            p.addRequired('gi',@(x) isa(x,'GraphInterface'));
            p.addParameter('timeDetection', 0 ,@isnumeric);
            p.addParameter('deltat', 0.01 ,@isnumeric);            
            p.addParameter('innerProblem', 'fminbound' ,@(s) validatestring(s, {'fminbound', 'pso'}));
            p.addParameter('plotCost', false , @islogical);
            p.addParameter('plotSwarm', false, @islogical);
            p.addParameter('plotSwarmIds', [], @isnumeric);  % Array of 1 or 2 ids which will be plotted through plotSwarm
            p.addParameter('faultIndex', 0, @isnumeric);
            p.addParameter('testMin', true, @islogical);
            p.addParameter('testMax', true, @islogical);
            
            p.parse(varargin{:});
            opts = p.Results;
            obj.res_gen = opts.res_gen;
            obj.gi = opts.gi;
            
            obj.timeDetection = opts.timeDetection;
            obj.dt = opts.deltat;
            obj.plotCost = opts.plotCost;
            obj.plotSwarm = opts.plotSwarm;
            obj.plotSwarmIds = opts.plotSwarmIds;
            obj.testMin = opts.testMin;
            obj.testMax = opts.testMax;
            
            % Set the inner problem method
            obj.inner_problem_method = opts.innerProblem;
            
            % Get a new dictionary
            obj.values = copy(obj.res_gen.values);
            
            % Get variable input ids for the whole residual generator
            var_ids = obj.res_gen.get_input_ids();
            
            % Separate the inputs from the faults
            fault_mask = obj.gi.isOfProperty(var_ids, 'isFault');
            input_mask = obj.gi.isOfProperty(var_ids, 'isInput');
            measured_mask = obj.gi.isOfProperty(var_ids, 'isMeasured');
            obj.fault_ids = var_ids(fault_mask);
            obj.input_ids = var_ids( (input_mask | measured_mask) & ~fault_mask);
            
            if opts.faultIndex == 0
                % Examine all faults
                obj.faultIndex = 1:length(obj.fault_ids);
            else
                if opts.faultIndex>length(obj.fault_ids)
                    error('Fault index specified is larger than the amount of available faults');
                end
                obj.faultIndex = opts.faultIndex;
            end
            
        end
        
        function [ cost ] = fitness_function_maximum(obj, pso_input_vec)
            % Objective function for maximum fault impact PSO
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question in the last element
            obj.values.setValue(obj.pso_input_ids, [], pso_input_vec);
            
            obj.res_gen.reset_state();  % Reset the state variables
            cost_initial = obj.residual_evaluation_cost(obj.values);
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            cost_penalty = obj.constraint_cost(pso_input_vec(1:(end-1)));    % pso_input_vec has the fault at its last position
            cost = cost_initial + cost_penalty;
            
            if obj.plotSwarm
                plotSwarm(obj.plotSwarmIds,cost_initial,'iter');
            end
        end
        
        function [ cost ] = fitness_function_minimum_inner(obj, input_vec, fault_value)
            % Objective function for maximum fault impact PSO
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question in the last element
            
            % Set the exterior input variable values
            obj.values.setValue(obj.input_ids, [], input_vec);
            % Set the fault variable value
            obj.values.setValue(obj.fault_id_current, [], fault_value);
            
            obj.res_gen.reset_state();  % Reset the state variables
            cost_initial = obj.residual_evaluation_cost(obj.values);
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            cost_penalty = obj.constraint_cost(input_vec);
            cost = cost_initial + cost_penalty;
        end
        
        function [ cost ] = residual_evaluation_cost(obj, values)
            % Residual evaluation cost to be minimized
            % Check if integration is needed
            if obj.res_gen.is_dynamic
                if obj.timeDetection > 0 % A horizon has been set
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
        
        function [ cost ] = fitness_function_minimum(obj, input_vec)
            % Objective function for minimum fault impact PSO
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question in the last element
            obj.values.setValue(obj.input_ids, [], input_vec);
            
            %% Maximum fault response search using Particle Swarm
            if strcmp(obj.inner_problem_method, 'pso')
                
                % Setup the inner optimization problem
                % Build the input bounds
                fault_id = obj.pso_input_ids(end);
                limits = obj.gi.getLimits(fault_id);
                lower_bound = limits(1);
                upper_bound = limits(2);
                % Setup the problem for particleswarm
                display_type = 'off';
                %             display_type = 'iter';
                particleswarm_options = optimoptions('particleswarm',...
                    'SwarmSize',10, ...
                    'Display',display_type, ...
                    'MaxIterations',100, ...
                    'MaxStallIterations', 5 ...
                    );
                problem.solver = 'particleswarm';
                problem.objective = @(f) obj.fitness_function_minimum_inner(input_vec, f);
                problem.nvars = 1; % Only 1 fault is the free variable
                problem.lb = lower_bound;
                problem.ub = upper_bound;
                problem.options = particleswarm_options;
                % Run the PSO to find the fault value which maximizes the fault
                % impact
                obj.res_gen.reset_state();  % Reset the state variables
                [fault_value, inner_cost] = particleswarm(problem);
                
            %% Maximum fault response search using fminbound
            elseif strcmp(obj.inner_problem_method, 'fminbound')
                
                % Build the input bounds
                fault_id = obj.pso_input_ids(end);
                limits = obj.gi.getLimits(fault_id);
                lower_bound = limits(1);
                upper_bound = limits(2);
                
                display_type = 'off';
                %             display_type = 'iter';
                fminbnd_options = optimset(...
                    'Display',display_type ...
                    );
                problem.solver = 'fminbnd';
                problem.objective = @(f) obj.fitness_function_minimum_inner(input_vec, f);
                problem.x1 = lower_bound;
                problem.x2 = upper_bound;
                problem.options = fminbnd_options;
                % Run the SINGLE-variable solver
                [ fault_value, inner_cost] = fminbnd(problem);
                
            else
                error('Unsupported maximization method');
            end
            
            %%
            
            % Evaluate the residual response for the given state and the
            % returned fault value
            obj.values.setValue(obj.fault_id_current, [], fault_value);
            cost_initial = abs(obj.res_gen.evaluate(obj.values));
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            cost_penalty = obj.constraint_cost(input_vec);    % pso_input_vec has the fault at its last position
            cost = cost_initial + cost_penalty;
            
            % If this particle has the best response, then store its fault
            % value
            if cost < obj.best_minimum_response_cost
                obj.inner_problem_fault_value = fault_value;
            end
        end
        
        function [ penalty ] = constraint_cost(obj, input_vec)
            % Calculate cost induced by constraints
            [~, error_eq] = obj.constraints(input_vec);
            
            % Set q
            q = max(0, abs(error_eq));
            
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
        
        function [inequality, equality] = constraints(obj, input_vec)
            % General nonlinear constraints for the optimization problem
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question
            inequality = []; % No inequality terms
            
            obj.values.setValue(obj.input_ids, [], input_vec); % Set the values of the input
            obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));% Zero the values of the faults
            
            obj.res_gen.reset_state();
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
        
        function [ fault_contribution ] = get_residual_sensitivity(obj)
            
            % Initialize the fault response vectors
            fault_contribution_maximum = zeros(size(obj.fault_ids));
            fault_contribution_minimum = inf*ones(size(fault_contribution_maximum));
            
            
            % Iterate over all faults
            for i=obj.faultIndex
                tic;
                
                if obj.testMax
                    %% Calculate the maximum fault contributions
                    % Reset fault values
                    obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
                    
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
                
                if obj.testMin
                    %% Calculate the minimum fault contributions
                    
                    obj.inner_problem_fault_value = nan;
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
                    args = [args obj.inner_problem_fault_value];
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

