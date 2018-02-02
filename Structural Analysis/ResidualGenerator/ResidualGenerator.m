classdef ResidualGenerator
    %RESIDUALGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        evaluators_list = {};
        values = Dictionary.empty;
        dt = 0.01;
        
        gi; % Handle to the original graph
        gd; % Handle to the directed subgraph
        
        all_input_ids;
        var_input_ids;  % IDs of the input variables
        
        is_dynamic = false;
        
    end
    
    methods
        function [ obj ] = ResidualGenerator(graphInitial, matched_graph, SCCs, values, dt)
            % Constructor
            
            % Set the time step
            if nargin >=5
                obj.dt = dt;
            end
            
            % Set the graph handles
            obj.gi = graphInitial;
            obj.gd = matched_graph;
            
            % Set the dictionary
            obj.values = values;
            
            % Create the evaluators after the initial values have been specified
            obj.evaluators_list = create_evaluators(graphInitial, matched_graph, SCCs, values, obj.dt);
            
            % Build and store all system input ids
            obj.all_input_ids = unique([ obj.gi.getVarIdByProperty('isInput') obj.gi.getVarIdByProperty('isMeasured')]);
            
            % Check if this res generator represents a dynamic system
            for i=1:length(obj.evaluators_list)
                if isa(obj.evaluators_list{i},'DAESolver')
                    obj.is_dynamic = true;
                end
            end
        end
        
        function [ residual ] = evaluate(obj, new_inputs)
            % Perform a single evaluation
            
            % Update the input dictionary
            obj.set_inputs(new_inputs);
            
            % Check if all input values are set
            var_dict_all_ids = obj.values.ids_array;
            var_known_ids = var_dict_all_ids(logical(obj.gi.isKnown(var_dict_all_ids)));
            dict_known_ids = obj.values.get_known_ids();    
            if ~all(ismember(var_known_ids, dict_known_ids))
%             if ~isequal(sort(var_known_ids), sort(dict_known_ids))
                error('Not all input/measured variable values known');
            end
            
            for i=1:length(obj.evaluators_list)
                evaluator = obj.evaluators_list{i};  % Grab the evaluator object
                [answer] = evaluator.evaluate();  % Perform the evaluation
            end
            
            % The last evaluation is the residual value
            residual = answer;            
        end
        
        function [ ] = set_inputs(obj, new_inputs)
            % Read and set the new inputs from a Dictionary
            
            if any(isinf(new_inputs.getValue(obj.all_input_ids))) % Not all inputs are set
                error('Not all new input values set');
            end
            
            obj.values.setValue(obj.all_input_ids, [], new_inputs.getValue(obj.all_input_ids));            
        end
        
        function [ input_ids ] = get_input_ids(obj)
            % Get the input variable ids
            input_ids = [];
            for i=1:length(obj.evaluators_list)
                input_ids = [ input_ids obj.evaluators_list{i}.var_input_ids ];
            end
            input_ids = unique(input_ids);
        end
        
        function [ ] = reset_state(obj)
            % Reset state variables
            for i=1:length(obj.evaluators_list)
                obj.evaluators_list{i}.reset_state();
            end
        end
        
    end
    
end

