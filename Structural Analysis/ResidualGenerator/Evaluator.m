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
        values;  % dictionary of all values
        
%         debug = true;
        debug = false;
    end
    
    methods
        function obj = Evaluator(gi, digraph, scc, dictionary)
            % Constructor
            obj.gi = gi;
            obj.digraph = digraph;
            obj.scc = scc;
            obj.values = dictionary;
            
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
            if obj.debug; fprintf('Evaluator: Built symbolic variables array: '); fprintf('%s, ',obj.sym_var_array); fprintf('\n'); end
            
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
            
        end
    
        function [] = set_output(obj, id, value)
        % Save a single output value with ID=id
            var_mask = ismember(obj.var_matched_ids, id);
            obj.answer(var_mask) = value;
        end
        
        function [ answer ] = evaluate(obj)
            % Evaluate the involved expressions given the stored values
            
            lexicon = obj.values.create_lexicon(obj.var_input_ids);
            if length(obj.scc)==1  % This is a singular SCC
                expressions_subs = subs(obj.expressions, lexicon);
                if ~isempty(obj.var_matched_ids)  % If this is not a residual generator
                    answer = vpasolve(expressions_subs, obj.sym_var_matched_array);
                    obj.values.setValue(obj.var_matched_ids, [], double(answer));
                else
                    answer = expressions_subs;
                    if obj.debug; fprintf('Evaluator: Residual evaluated to %g\n',answer(1)); end
                end
                if obj.debug; fprintf('Evaluator: Evaluated %s to %g\n', obj.expressions, answer); end
                if obj.debug; fprintf('Evaluator: Input variables: '); fprintf('%s, ',obj.sym_var_input_array); fprintf('\n'); end
                if obj.debug; fprintf('Evaluator: Input values: '); fprintf('%g, ',obj.values.getValue(obj.var_input_ids)); fprintf('\n'); end
            else  % This is a non-singular SCC
                if any(obj.gi.getPropertyById(obj.scc,'isDynamic'))
                    error('DAEs should be handled by a DAESolver object');                    
                else  % This is an algebraic SCC
                    expressions_subs = subs(obj.expressions, lexicon);
                    answer = vpasolve(expressions_subs, obj.sym_var_matched_array);
                    obj.values.parse_lexicon(answer);
                end
            end
            
        end
        
    end
    
end

