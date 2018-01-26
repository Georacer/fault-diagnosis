classdef Differentiator < Evaluator
    %DIFFERENTIATOR Specialized Evaluator to handle explicit
    %differentiations
    %   Detailed explanation goes here
    
    properties
        state;
        prev_state = 0;
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
            end
            
            % Find the integral and derivative variables
            for i=1:length(obj.var_input_ids)
                var_id = obj.var_input_ids(i);
                edge_id = gi.getEdgeIdByVertices(obj.scc, var_id);
                if gi.isIntegral(edge_id)
                    obj.integral_id = var_id;
                    obj.derivative_id = obj.var_matched_ids;
                elseif gi.isDerivative(edge_id)
                    obj.derivative_id = var_id;
                    obj.integral_id = obj.var_matched_ids;
                else
                    error('Differentiator variables must be either integrals or derivatives')
                end
            end
            
        end
        
%         function [] = set_state(obj, value)
%             if obj.debug; fprintf('Differentiator: input set to %d\n', value); end
%             obj.state = value;
%         end
        
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
                int_index = find(obj.var_input_ids==obj.integral_id); % Find the integral id
                der_index = find(obj.var_input_ids==obj.derivative_id); % Find the integral id
                obj.set_state(obj.values(int_index)); % Set the integral variable input as the state
                answer = obj.values(der_index) - obj.get_derivative() ;
            end
        end
        
    end
    
end

