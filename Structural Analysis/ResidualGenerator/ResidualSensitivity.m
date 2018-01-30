classdef ResidualSensitivity
    %RESIDUALSENSITIVITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gi
        res_gen
        values = Dictionary.empty;
        lower_bounds
        upper_bounds
        pso_input_ids
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
            fault_ids = var_ids(fault_mask);
            input_ids = var_ids( (input_mask | measured_mask) & ~fault_mask);
            
            % Pick one fault and build the input array
            fault_index = 4;
            obj.pso_input_ids = [input_ids fault_ids(fault_index)];
            
            % Build the input bounds
            limits = obj.gi.getLimits(obj.pso_input_ids);
            obj.lower_bounds = limits(:,1);
            obj.upper_bounds = limits(:,2);
        end
        
        function [ cost ] = cost_function(obj, input_vec)
            
            obj.values.setValue(obj.pso_input_ids, [], input_vec);
                
            cost = -abs(obj.res_gen.evaluate(obj.values));
            if isinf(cost)
                error('Cost is not expected to be inf');
            end
            
        end
        
        function [ args, sensitivity_vector] = get_residual_sensitivity(obj)
            % Perform the Particle Swarm Optimization
            options = optimoptions('particleswarm','SwarmSize',30,'Display','iter','MaxIterations',10);
            [args, sensitivity_vector] = particleswarm(@obj.cost_function, length(obj.pso_input_ids), obj.lower_bounds, obj.upper_bounds, options);
        end
        
    end
        
    end
    
