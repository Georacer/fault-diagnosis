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
        function obj = Differentiator(gi, digraph, scc)
            % Constructor
            obj = obj@Evaluator(gi, digraph, scc);
            
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
                    obj.isIntegrator = True;
                elseif gi.isDerivative(edge_id)
                    obj.isDifferentiator = True;
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
                elseif gi.isDerivative(edge_id)
                    obj.derivative_id = var_id;
                else
                    error('Differentiator variables must be either integrals or derivatives')
                end
            end
            
        end
        
        function [] = set_state(obj, value)
            obj.state = value;
        end
        
        function [] = set_dt(obj, value)
            obj.dt = value;
        end
        
        function [answer] = get_derivative(obj)
            answer = (obj.state - obj.prev_state)/obj.dt;
            obj.prev_state = obj.state;
        end
        
        function [answer] = get_integral(obj)
            answer = obj.prev_state + obj.state*obj.dt;
            obj.prev_state = obj.state;
        end
        
        function [answer] = evaluate(obj)
            if obj.isIntegrator
                obj.set_state(obj.values);
                answer = obj.get_integral();
            elseif obj.isDifferentiator
                obj.set_state(obj.values);
                answer = obj.get_derivative();
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

