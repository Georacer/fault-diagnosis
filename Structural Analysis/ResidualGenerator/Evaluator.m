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
        expressions_solved;  % Array of pre-solved symbolic expressions
        expressions_solved_handle;  % Array of pre-solve numeric expressions
        values;  % dictionary of all values
        is_res_gen = false;
        
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
%             obj.sym_var_input_array = setdiff(obj.sym_var_array, obj.sym_var_matched_array);
            obj.var_input_ids = setdiff(obj.var_ids, obj.var_matched_ids);
            obj.sym_var_input_array = sym.empty;
            for i=1:length(obj.var_input_ids)
                var_id = obj.var_input_ids(i);
                obj.sym_var_input_array(end+1) = sym(obj.gi.getAliasById(var_id));
            end
            
            
            % Build the symbolic expressions array
            obj.expressions = sym.empty;
            for i=1:length(obj.scc)
                if ~gi.getPropertyById(scc(i),'isDynamic')  % This equation is not a differentiation
                    obj.expressions(i) = sym(obj.gi.getExpressionById(scc(i)));
                end
            end
            
            % Solve the expressions to get a pre-baked answer
            if length(obj.scc)==1  % This is a singular SCC
                if ~isempty(obj.var_matched_ids)  % If this is not a residual generator
                    obj.expressions_solved = vpasolve(obj.expressions, obj.sym_var_matched_array); % Store the pre-solved expressions
                    obj.expressions_solved_handle = matlabFunction(obj.expressions_solved, 'Vars', obj.sym_var_input_array, 'Outputs', obj.gi.getAliasById(obj.var_matched_ids));
                else  % This is a residual generator
                    obj.is_res_gen = true; % No pre-solved expression to store, we just need to evaluate it
                    obj.expressions_solved_handle = matlabFunction(obj.expressions, 'Vars', obj.sym_var_input_array);
                end
                
            else  % This is a non-singular SCC
                if any(obj.gi.getPropertyById(obj.scc,'isDynamic'))
                    error('DAEs should be handled by a DAESolver object');                    
                else  % This is an algebraic SCC
                    obj.expressions_solved = vpasolve(obj.expressions, obj.sym_var_matched_array);
                    % Since vpasolve sorts the output arguments, I have to
                    % re-sort them in the order of their var_matched_ids
                    field_names = obj.gi.getAliasById(obj.var_matched_ids);
                    [field_names_sorted, permutations] = sort(field_names);
                    solution_names = fieldnames(obj.expressions_solved);
                    assert(isempty(setxor(field_names, solution_names))); % Verify the expected matched variable names
                    function_array = sym.empty;
                    for i=1:length(field_names)
                        function_array(permutations(i)) = obj.expressions_solved.(field_names_sorted{i});
                    end
                    obj.expressions_solved_handle = matlabFunction(function_array, 'Vars', obj.sym_var_input_array, 'Outputs', obj.gi.getAliasById(obj.var_matched_ids));
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
            
%             lexicon = obj.values.create_lexicon(obj.var_input_ids);
            values_vector = obj.values.getValue(obj.var_input_ids);
            if length(obj.scc)==1  % This is a singular SCC
                if obj.is_res_gen
%                     answer = subs(obj.expressions, lexicon);
                    argument_cell = num2cell(values_vector);
                    answer = obj.expressions_solved_handle(argument_cell{:});
                    if obj.debug; fprintf('Evaluator: Residual evaluated to %g\n',answer); end
                else
%                     answer = subs(obj.expressions_solved, lexicon);
                    argument_cell = num2cell(values_vector);
                    answer = obj.expressions_solved_handle(argument_cell{:});
                    obj.values.setValue(obj.var_matched_ids, [], answer);
                end
                
                if obj.debug; fprintf('Evaluator: Evaluated %s to %g\n', obj.expressions, answer); end
                if obj.debug; fprintf('Evaluator: Input variables: '); fprintf('%s, ',obj.sym_var_input_array); fprintf('\n'); end
                if obj.debug; fprintf('Evaluator: Input values: '); fprintf('%g, ',obj.values.getValue(obj.var_input_ids)); fprintf('\n'); end
            else  % This is a non-singular SCC
                if any(obj.gi.getPropertyById(obj.scc,'isDynamic'))
                    error('DAEs should be handled by a DAESolver object');                    
                else  % This is an algebraic SCC
%                     answer = struct();
%                     answer_fields = fieldnames(obj.expressions_solved);
%                     for i=1:length(answer_fields)
%                         answer.(answer_fields{i}) = subs(obj.expressions_solved.(answer_fields{i}), lexicon);
%                     end
%                     obj.values.parse_lexicon(answer);
                    argument_cell = num2cell(values_vector);
                    answer = obj.expressions_solved_handle(argument_cell{:});
                    obj.values.setValue(obj.var_matched_ids, [], answer);
                end
            end
            
        end
        
    end
    
end

