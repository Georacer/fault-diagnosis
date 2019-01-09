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
            
            % Create a new graph with no dynamic equations
            static_graph = copy(digraph);
            dynamic_equ_ids = static_graph.getEquIdByProperty('isDynamic');  % Find all dynamic variables
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
            % Check if all evaluators instantiated correctly
            if any(cellfun(@isempty,obj.sub_evaluators))
                error('One of the subevaluators of the DAE did not instantiate');
            end
            
        end

        function [] = set_dt(obj, value)
            obj.dt = value;
        end
        
        function [] = reset_state(obj, values)
            if nargin<2
                values = [];
            end
            for i=1:length(obj.sub_evaluators)
                obj.sub_evaluators{i}.reset_state(values);
            end
        end
        
        function [answer] = evaluate(obj)
        % Evaluate the involved expressions given the stored values
        
            for i=1:length(obj.sub_evaluators)
                % Evaluate each sub_evaluator
                answer = obj.sub_evaluators{i}.evaluate();
                           
            end
        end
        
    end
    
end

