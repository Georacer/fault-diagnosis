classdef ResidualSensitivity
    %RESIDUALSENSITIVITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gi
        res_gen
        values = Dictionary.empty;
        fault_ids
        input_ids
        pso_input_ids
        
        debug = true;
        %         debug = false;
    end
    
    methods
        function [ obj ] = ResidualSensitivity( varargin )
            % Constructor
            
            p = inputParser;
            
            p.addRequired('res_gen',@(x) isa(x, 'ResidualGenerator'));
            p.addRequired('gi',@(x) isa(x,'GraphInterface'));
            % p.addParameter('boundType', 'upper' ,@(s) validatestring(s, {'upper', 'lower'}));
            
            p.parse(varargin{:});
            opts = p.Results;
            obj.res_gen = opts.res_gen;
            obj.gi = opts.gi;
            
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
            
        end
        
        function [ cost ] = fitness_function(obj, pso_input_vec)
            % Objective function for PSO
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question
            obj.values.setValue(obj.pso_input_ids, [], pso_input_vec);
            
            obj.res_gen.reset_state();  % Reset the state variables
            cost_initial = -abs(obj.res_gen.evaluate(obj.values));
            if isinf(cost_initial)
                error('Cost is not expected to be inf');
            end
            
            % Calculate cost induced by constraints
            [~, error_eq] = obj.constraints(pso_input_vec);
            
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
            if q < 1
                gamma = 1;
            else
                gamma = 2;
            end
            
            cost_penalty = theta*q^gamma;
            
            cost = cost_initial + cost_penalty;
        end
        
        function [inequality, equality] = constraints(obj, pso_input_vec)
            % General nonlinear constraints for the optimization problem
            % input_vec: indexed vector with input variable values,
            % including the fault variable in question
            inequality = []; % No inequality terms
            
            input_vec = pso_input_vec(1:(end-1)); % pso_input_vec has the fault at its last position
            obj.values.setValue(obj.input_ids, [], input_vec); % Set the values of the input
            obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));% Zero the values of the faults
            
            obj.res_gen.reset_state();
            equality = obj.res_gen.evaluate(obj.values);
            if isinf(equality)
                error('Inequality is not expected to be inf');
            end
        end
        
        function [ fault_response_vector ] = get_residual_sensitivity(obj)
            
            fault_response_vector = zeros(size(obj.fault_ids));
            
            % Iterate over all faults
            for i=1:length(obj.fault_ids)
                
                % Reset fault values
                obj.values.setValue(obj.fault_ids, [], zeros(size(obj.fault_ids)));
                
                % Pick one fault and build the input array
                fault_index = i;
                obj.pso_input_ids = [obj.input_ids obj.fault_ids(fault_index)];
                
                % Build the input bounds
                limits = obj.gi.getLimits(obj.pso_input_ids);
                lower_bounds = limits(:,1);
                upper_bounds = limits(:,2);
                
                % Setup the problem for particleswarm
                swarm_size = 100;
                max_iterations = 200;
                max_stall_iterations = 10;
                if obj.debug
                    display_type = 'iter';
                else
                    display_type = 'off';
                end
                particleswarm_options = optimoptions('particleswarm','SwarmSize',swarm_size,'Display',display_type,'MaxIterations',max_iterations, 'MaxStallIterations', max_stall_iterations);
                
                % Setup the problem for pso_opt toolbox
                pso_options = psooptimset(...
                    'PopulationSize',swarm_size,...
                    'Generations',max_iterations,...
                    'StallGenLimit',max_stall_iterations,...
                    'ConstrBoundary','soft',...
                    'Display','diagnose'...
                    );
                problem.fitnessfcn = @obj.fitness_function;
                problem.nvars = length(obj.pso_input_ids);
                problem.Aineq = [];
                problem.bineq = [];
                problem.Aeq = [];
                problem.beq = [];
                problem.LB = lower_bounds;
                problem.UB = upper_bounds;
                %                 problem.nonlcon = @obj.constraints;
                problem.nonlcon = [];
                problem.options = pso_options;
                
                % Run the PSO
                [args, sensitivity] = particleswarm(@obj.fitness_function, length(obj.pso_input_ids), lower_bounds, upper_bounds, particleswarm_options);
                %                 [args, sensitivity] = pso(problem);
                
                
                obj.values.setValue(obj.pso_input_ids, [], args);
                obj.res_gen.reset_state();  % Reset the state variables
                fault_response_vector(i) = -abs(obj.res_gen.evaluate(obj.values));
                
                if obj.debug
                    fprintf('Residual Sensitivity: Solution found at:\n');
                    for j=1:length(args)
                        alias = obj.gi.getAliasById(obj.pso_input_ids(j));
                        fprintf('%5s = %f\n', alias{1}, args(j));
                    end
                    
                    fprintf('with output: \n')
                    obj.values.setValue(obj.pso_input_ids, [], args);
                    obj.res_gen.evaluate(obj.values);
                    disp(obj.values);
                end
                
            end
        end
        
    end
    
end

