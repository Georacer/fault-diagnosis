classdef DAESolver < Evaluator
    %DAESOLVER Specialized Evaluator for general DAE SCCs
    %   Detailed explanation goes here
    
    properties
        sub_evaluators = {};  % For evaluation of internal SCCs
        dt;
        integral_var_ids;
    end
    
    methods
        
        function obj = DAESolver(gi, digraph, scc, dictionary, dt)
            % Constructor
            obj = obj@Evaluator(gi, digraph, scc, dictionary);
            
            obj.dt = dt;
            
%             % Find all dynamic variables
%             dynamic_equ_ids = digraph.getEquIdByProperty('isDynamic');
%             obj.integral_var_ids = zeros(1,length(dynamic_equ_ids));
%             for i=1:length(obj.integral_var_ids)
%                 edge_ids = digraph.getEdges(dynamic_equ_ids(i));
%                 for j=1:length(edge_ids)
%                     if digraph.getPropertyById(edge_ids(j),'isIntegral')
%                         var_id = digraph.getVariables(edge_ids(j));
%                         obj.integral_var_ids(i) = var_id;
%                         break
%                     end
%                 end
%             end
%             % Build an array to hold their values and initialize it
%             obj.values_state = zeros(1,length(obj.integral_var_ids));
            
            % Create a new graph with no dynamic equations
            static_graph = copy(digraph);
            dynamic_equ_ids = static_graph.getEquIdByProperty('isDynamic');  % Find all dynamic variables
%             % Mark each integral variable as known
%             integral_variables = zeros(1,length(dynamic_equ_ids));
%             for i=1:length(integral_variables)
%                 edge_ids = static_graph.getEdges(dynamic_equ_ids(i));
%                 for j=1:length(edge_ids)
%                     if static_graph.getPropertyById(edge_ids(j),'isIntegral')
%                         var_id = static_graph.getVariables(edge_ids(j));
%                         integral_variables(i) = var_id;
% %                         static_graph.setKnown(var_id);
%                         break
%                     end
%                 end
%             end
            % Delete dynamic equations
            static_graph.deleteEquations(dynamic_equ_ids);
            % Delete all unmatched variables
            unmatched_var_ids = static_graph.getVarIdByProperty('isMatched',false);
            static_graph.deleteVariables(unmatched_var_ids, false);
            static_graph.adjacency.parseModel();
            
            % Find its SCCs
            sccs_ordered = findCalcSequence(static_graph);
            % Create sub evaluators for static equations
            sub_evaluators_static = create_evaluators(gi, digraph, sccs_ordered, obj.values);
            % Add evaluators for explicit integrations
            sub_evaluators_dynamic = create_evaluators(gi, digraph, num2cell(dynamic_equ_ids), obj.values, obj.dt);
            obj.sub_evaluators = [sub_evaluators_static sub_evaluators_dynamic];
            
        end
        
%         function [] = set_inputs(obj, values)
%         % Save the known variables values
%             set_inputs@Evaluator(obj, values);
%             
%             % Iterate over each sub_evaluator and fill
%             for i=1:length(obj.sub_evaluators)
%                 if isa(obj.sub_evaluators{i},'Differentiator')
%                     continue  % Differentiators don't need initialization. Their must be generated as answers from differential equations
%                 end
%                 rel_var_ids = obj.sub_evaluators{i}.var_input_ids;
%                 for j=1:length(rel_var_ids)
%                     id = rel_var_ids(j);
%                     input_value = obj.values(ismember(obj.var_input_ids, id));  % Search id in input values
%                     state_value = obj.values_state(ismember(obj.integral_var_ids, id));  % Search id in state values
%                     if ~isempty(input_value)
%                         obj.sub_evaluators{i}.set_input(id, input_value);
%                     elseif ~isempty(state_value)
%                         obj.sub_evaluators{i}.set_input(id, state_value);
%                     else
%                         error('Input variable with id=%d not found in inputs nor states', id);
%                     end
%                 end
%             end
%         end
        
%         function [] = clear_values(obj)
%         % Clear the known variables values
%             clear_values@Evaluator(obj);
%             for i=1:length(obj.sub_evaluators)
%                 obj.sub_evaluators{i}.clear_values();
%             end
%         end
        
        function [] = set_dt(obj, value)
            obj.dt = value;
        end
        
        function [answer] = evaluate(obj)
        % Evaluate the involved expressions given the stored values
        
            for i=1:length(obj.sub_evaluators)
                % Evaluate each sub_evaluator
                answer = obj.sub_evaluators{i}.evaluate();
                
%                 % Store the new values to the answer variable and
%                 % the future sub_evaluators
%                 answer_ids = obj.sub_evaluators{i}.var_matched_ids;
%                 for j=1:length(answer_ids)
%                     obj.set_output(answer_ids(j), answer(j));
%                     for k=i:length(obj.sub_evaluators)
%                         obj.sub_evaluators{k}.set_input(answer_ids(j), answer(j));
%                     end
%                 end                
            end
        end
        
    end
    
end

