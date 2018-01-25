classdef Evaluator < handle
    %EVALUATOR Evaluation unit for symbolic evaluation of equations
    %   Detailed explanation goes here
    
    properties
        gi;  % The overall graph interface
        digraph;  % Graph interface to the directed graph
        scc;  % set of involving equations
        var_ids;
        sym_var_array;  % array of symbolic variables involved in the equation
        var_input_ids;
        sym_var_input_array;  % array of input symbolic variables
        var_matched_ids;
        sym_var_matched_array;  % array of symbolic variables to be solved for
        expressions;  % array of symbolic expressions
        values;
    end
    
    methods
        function obj = Evaluator(gi, digraph, scc)
            % Constructor
            obj.gi = gi;
            obj.digraph = digraph;
            obj.scc = scc;
            
            % Build the symbolic variables array
            equ_ids = scc;
            obj.var_ids = obj.gi.getVariables(equ_ids);
            obj.sym_var_array = sym.empty;
            counter = 1;
            for var_id = obj.var_ids
                obj.sym_var_array(end+1) = sym(obj.gi.getAliasById(var_id));
                counter = counter + 1;
            end
            
            % Build the symbolic matched variables array
            obj.var_matched_ids = obj.digraph.getMatchedVars(scc);
            obj.sym_var_matched_array = sym.empty;
            for i=1:length(obj.var_matched_ids)
                var_id = obj.var_matched_ids(i);
                obj.sym_var_matched_array(end+1) = sym(obj.gi.getAliasById(var_id));
            end
            
            % Build the symbolic input variables array
            obj.sym_var_input_array = setdiff(obj.sym_var_array, obj.sym_var_matched_array);
            obj.var_input_ids = setdiff(obj.var_ids, obj.var_matched_ids);
            
            % Build the symbolic expressions array
            obj.expressions = sym.empty;
            for i=1:length(obj.scc)
                if ~gi.getPropertyById(scc(i),'isDynamic')  % This equation is not a differentiation
                    obj.expressions(i) = sym(obj.gi.getExpressionById(scc(i)));
                end
            end
            
            % Build the values array
            obj.values = inf*ones(1,length(obj.var_input_ids));   
            
        end
        
        function [] = set_inputs(obj, values)
        % Save the known variables values
            obj.values = values;
        end
        
        function [] = clear_values(obj)
        % Clear the known variables values
            obj.values = obj.values * inf;
        end
        
        function [answer] = evaluate(obj)
        % Evaluate the involved expressions given the stored values
        
            if length(obj.scc)==1  % This is a singular SCC
                expressions_subs = subs(obj.expressions, obj.sym_var_input_array, obj.values);
                if ~isempty(obj.var_matched_ids)  % If this is not a residual generator
                    answer = solve(expressions_subs, obj.sym_var_matched_array);
                else
                    answer = expressions_subs;
                end
            else  % This is a non-singular SCC
                error('Code not implemented yet');
            end
        end
    end
    
end

