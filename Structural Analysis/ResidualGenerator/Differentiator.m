classdef Differentiator < Evaluator
    %DIFFERENTIATOR Specialized Evaluator to handle explicit
    %differentiations
    %   Detailed explanation goes here
    
    properties
        state;
        prev_state;
        dt;
        isIntegrator = false;
        isDifferentiator = false;
        integral_id;
        derivative_id;
        
    end
    
    methods
        function obj = Differentiator(gi, digraph, scc, dictionary, dt)
            % Constructor
            obj = obj@Evaluator(gi, digraph, scc, dictionary);
            
            obj.dt = dt;
            
            if length(obj.scc)>1
                error('Differentiator must be a singular SCC');
            end
            if length(obj.var_matched_ids)>1
                error('Differentiator must be a singular SCC');
            end
            
            % Find the Differentiator causality
            if ~isempty(obj.var_matched_ids)
                edge_id = gi.getEdgeIdByVertices(obj.scc, obj.var_matched_ids);
                if gi.isIntegral(edge_id)
                    obj.isIntegrator = true;
                elseif gi.isDerivative(edge_id)
                    obj.isDifferentiator = true;
                else
                    error('Differentiator must be in either derivative or integral causality');
                end
            else % The differentiator is a residual generator, use it in differential causality
                
            end
            
            % Find the integral and derivative variables
            for i=1:length(obj.var_input_ids)
                var_id = obj.var_input_ids(i);
                edge_id = gi.getEdgeIdByVertices(obj.scc, var_id);
                if gi.isIntegral(edge_id)
                    obj.integral_id = var_id;
                    obj.derivative_id = setdiff(obj.var_ids, var_id);
                elseif gi.isDerivative(edge_id)
                    obj.derivative_id = var_id;
                    obj.integral_id = setdiff(obj.var_ids, var_id);
                else
                    error('Differentiator variables must be either integrals or derivatives')
                end
            end
            
            % Initialize the Differentiator state
            integrator_value = obj.values.getValue(obj.integral_id);
            % If not set, set to 0
            if isinf(integrator_value)
                obj.prev_state = 0;
            else
                obj.prev_state = integrator_value;
            end
            obj.initial_state = obj.prev_state;  % Store the initialization value
            
        end
        
%         function [] = set_state(obj, value)
%             if obj.debug; fprintf('Differentiator: input set to %d\n', value); end
%             obj.state = value;
%         end

        function [] = reset_state(obj)
            obj.prev_state = obj.initial_state;
            obj.values.setValue(obj.integral_id, [], obj.prev_state);
        end
        
        function [] = set_dt(obj, value)
            obj.dt = value;
        end
        
        function [answer] = get_derivative(obj)
            input = obj.values.getValue(obj.integral_id);
            answer = (input - obj.prev_state)/obj.dt;
            obj.prev_state = input;
        end
        
        function [answer] = get_integral(obj)
            input = obj.values.getValue(obj.derivative_id);
            answer = obj.prev_state + input*obj.dt;
            obj.prev_state = answer;
        end
        
        function [answer] = evaluate(obj)
            if obj.isIntegrator
                answer = obj.get_integral();
                obj.values.setValue(obj.integral_id,[],answer);
                if obj.debug; fprintf('Differentiator: Adding %g*%g to integral\n', obj.prev_state, obj.dt); end
            elseif obj.isDifferentiator
                answer = obj.get_derivative();
                obj.values.setValue(obj.derivative_id,[],answer);
                if obj.debug; fprintf('Differentiator: Got %g and differentiated by %g\n', obj.prev_state, obj.dt); end
            else  % The Differentiator is a residual generator
                % We shall solve it in derivative causality
                answer = obj.values.getValue(obj.derivative_id, []) - obj.get_derivative() ;
            end
        end
        
    end
    
end

