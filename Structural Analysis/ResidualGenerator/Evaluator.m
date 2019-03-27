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
        expressions_fhandle; % Numeric anonymous function handle for algebraic equations set
        expressions_solved;  % Array of pre-solved symbolic expressions
        expressions_solved_handle;  % Array of pre-solve numeric expressions
        solver_method = 0;
        values;  % dictionary of all values
        initial_state;  % Initialization state
        is_res_gen = false;
        is_dynamic = false;
        
        DEF_SOLVER_SOLVE = 1;
        DEF_SOLVER_VPA = 2;
        DEF_SOLVER_FSOLVE = 3;
        
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
                assume(obj.sym_var_array(end),'real'); % Assume real variables
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
                    equation_expression = obj.gi.getExpressionById(obj.scc(i));
                    if isempty(equation_expression)
                        error('No expression was provided with equation %d',obj.scc(i));
                    end
                    if obj.debug
                        fprintf('Evaluator: building expression: %s\n', equation_expression{:});
                    end
                    try
                        obj.expressions(i) = sym(equation_expression{:});
                    catch e
                        rethrow(e);
%                         if strcmp(e.identifier, 'symbolic:specfunc:ExpectingArithmeticalExpression')
%                             rethrow(e); % Matlab failed to create the arithmetic expression
%                         else
%                             error('Unknown symbolic toolbox error');
%                         end
                    end
                end
            end
            
            if isa(obj, 'DAESolver')
                % This part of the constructor should only be called by
                % sub-SCCs
            elseif isa(obj, 'Differentiator')
                % This part of the constructor should only be handled
                % explicitly by Differentiator subclass
            else
                % Solve the expressions to get a pre-baked answer
                if length(obj.scc)==1  % This is a singular SCC
                    if ~isempty(obj.var_matched_ids)  % If this is not a residual generator
                        try
                            obj.expressions_solved = vpasolve(obj.expressions, obj.sym_var_matched_array); % Store the pre-solved expressions
                            obj.solver_method = obj.DEF_SOLVER_VPA;
                            if isempty(obj.expressions_solved)
                                error('vpasolve could not solve for expression');
                            end
                        catch e
                            warning('vpasolve could not solve for expression');
                            try
                                obj.expressions_solved = solve(obj.expressions, obj.sym_var_matched_array); % Store the pre-solved expressions
                                obj.solver_method = obj.DEF_SOLVER_SOLVE;
                                if isempty(obj.expressions_solved)
                                    error('solve could not solve for expression');
                                end
                            catch e
                                try % solve couldn't find an analytical expression. Trying a numerical one.
                                    obj.solver_method = obj.DEF_SOLVER_FSOLVE;
                                    f = symfun(obj.expressions, [obj.sym_var_matched_array obj.sym_var_input_array]); % Create a symbolic function
                                    obj.expressions_fhandle = matlabFunction(f, 'Vars', {obj.sym_var_matched_array obj.sym_var_input_array}); % Create an anonymous function, splitting input and parameter variables
                                catch e
                                    if obj.debug; fprintf('Evaluator: Failed to solve singular SCC\n'); end
                                    rethrow(e);  %This equation cannot be solved at all with MATLAB's computer methods
                                end
                            end
                        end
                        try
                            obj.expressions_solved_handle = matlabFunction(obj.expressions_solved, 'Vars', obj.sym_var_input_array, 'Outputs', obj.gi.getAliasById(obj.var_matched_ids));
                        catch e
                            if obj.debug; fprintf('Evaluator: Failed to instantiate singular SCC evaluation\n'); end
                            rethrow(e);
                        end
                    else  % This is a residual generator
                        obj.is_res_gen = true; % No pre-solved expression to store, we just need to evaluate it
                        try
                            obj.expressions_solved_handle = matlabFunction(obj.expressions, 'Vars', obj.sym_var_input_array);
                        catch e
                            if obj.debug; fprintf('Evaluator: Failed to instantiate residual generator'); end
                            rethrow(e);
                        end
                    end
                else  % This is a non-singular SCC
                    if any(obj.gi.getPropertyById(obj.scc,'isDynamic'))
                        obj.is_dynamic = true;
                        error('DAEs should be handled by a DAESolver object');
                    else  % This is an algebraic SCC
                        try
                            obj.solver_method = obj.DEF_SOLVER_VPA;
                            obj.expressions_solved = vpasolve(obj.expressions, obj.sym_var_matched_array, 'random', true);
                            
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
                            
                        catch e % vpasolve couldn't find an analytic solution, using numerical fsolve
                            try
                                obj.solver_method = obj.DEF_SOLVER_FSOLVE;
                                f = symfun(obj.expressions, [obj.sym_var_matched_array obj.sym_var_input_array]); % Create a symbolic function
                                obj.expressions_fhandle = matlabFunction(f, 'Vars', {obj.sym_var_matched_array obj.sym_var_input_array}); % Create an anonymous function, splitting input and parameter variables
                            catch e
                                if obj.debug; fprintf('Evaluator: Failed to solve non-singular SCC\n'); end
                                rethrow(e);  %This equation cannot be solved at all with MATLAB's computer methods
                            end
                        end
                    end
                end
            end
            
        end
    
        function [] = set_output(obj, id, value)
        % Save a single output value with ID=id
            var_mask = ismember(obj.var_matched_ids, id);
            obj.answer(var_mask) = value;
        end
        
        function [] = reset_state(obj, values)
            % Empty method, to be overriden by Differentiator and DAESolver
        end
        
        function [ answer ] = evaluate(obj)
            % Evaluate the involved expressions given the stored values
            
            values_vector = obj.values.getValue(obj.var_input_ids);
            if length(obj.scc)==1  % This is a singular SCC
                if obj.is_res_gen
                    argument_cell = num2cell(values_vector);
                    answer = obj.expressions_solved_handle(argument_cell{:});
                    answer = real(answer);  %TODO: must decide about the answer domain policy
                    if length(answer)>1
                        answer = answer(1);
                    end
                    if obj.debug; fprintf('Evaluator: Residual evaluated to %g\n',answer); end
                else
                    switch obj.solver_method
                        case {obj.DEF_SOLVER_SOLVE, obj.DEF_SOLVER_VPA}
                            argument_cell = num2cell(values_vector);
                            answer = obj.expressions_solved_handle(argument_cell{:});
                            answer = real(answer);  %TODO: must decide about the answer domain policy
                            if length(answer)>1 % This may return a correct answer but which may throw a residual off
                                answer = answer(1);
                            end
                            obj.values.setValue(obj.var_matched_ids, [], answer);
                        case obj.DEF_SOLVER_FSOLVE
                            g = @(x)obj.expressions_fhandle(x,values_vector);
                            prev_answer = obj.values.getValue(obj.var_matched_ids);
                            [answer, ~, exitflag] = fzero(g, prev_answer, optimset('Display', 'off'));
                            switch exitflag
                                case {1}
                                    % System solved
                                    obj.values.setValue(obj.var_matched_ids, [], answer);
                                case {-5}
                                    obj.values.setValue(obj.var_matched_ids, [], answer);
                                    warning('Could not solve algebraic equation system. Returning best answer');
                                otherwise
                                    error('Unhandled fsolve flag %d', exitflag);
                            end
                        otherwise
                            error('Unhandled solver method');
                    end
                end
                
                if obj.debug; fprintf('Evaluator: Evaluated %s to %g\n', obj.expressions, answer); end
                if obj.debug; fprintf('Evaluator: Input variables: '); fprintf('%s, ',obj.sym_var_input_array); fprintf('\n'); end
                if obj.debug; fprintf('Evaluator: Input values: '); fprintf('%g, ',obj.values.getValue(obj.var_input_ids)); fprintf('\n'); end
            else  % This is a non-singular SCC
                if obj.is_dynamic
                    error('DAEs should be handled by a DAESolver object');                    
                else  % This is an algebraic SCC
                    switch obj.solver_method
                        case obj.DEF_SOLVER_VPA
                            argument_cell = num2cell(values_vector);
                            answer = obj.expressions_solved_handle(argument_cell{:});
                            answer = real(answer);  %TODO: must decide about the answer domain policy
                            obj.values.setValue(obj.var_matched_ids, [], answer);
                        case obj.DEF_SOLVER_FSOLVE
                            g = @(x)obj.expressions_fhandle(x,values_vector);
                            prev_answer = obj.values.getValue(obj.var_matched_ids);
                            [answer, ~, exitflag] = fsolve(g, prev_answer, optimoptions('fsolve', 'Display', 'off'));
                            switch exitflag
                                case {1,2,3,4}
                                    % System solved
                                    obj.values.setValue(obj.var_matched_ids, [], answer);                                    
                                case {0, -2, -3}
                                    obj.values.setValue(obj.var_matched_ids, [], answer); 
                                    warning('Could not solve algebraic equation system. Returning best answer');
                                otherwise
                                    error('Unhandled fsolve flag %d', exitflag);
                            end
                        otherwise
                            error('Unhandled SCC solver method');
                    end
                end
            end
            
        end
        
        function [ ] = displayEquations(obj)
            if length(obj.scc)==1
                if obj.is_res_gen
                    fprintf('R = %s\n', char(obj.expressions));
                else
                    switch obj.solver_method
                        case {obj.DEF_SOLVER_VPA, obj.DEF_SOLVER_SOLVE}
                            output_alias = obj.gi.getAliasById(obj.var_matched_ids);
                            fprintf('%s = %s\n', output_alias{1}, char(obj.expressions_solved));
                            
                        case obj.DEF_SOLVER_FSOLVE
                            output_alias = obj.gi.getAliasById(obj.var_matched_ids);
                            fprintf('%s: 0 = %s\n', output_alias{1}, char(obj.expressions));
                        otherwise
                            error('Unhandled solver type');
                    end
                end
            else
                fprintf('--- SCC start ---------------\n');
                if obj.solver_method == obj.DEF_SOLVER_VPA
                    output_aliases = fieldnames(obj.expressions_solved);
                    for output_idx = 1:length(obj.scc)
                        var_alias = output_aliases{output_idx};
                        expression = char(obj.expressions_solved.(var_alias));
                        fprintf('%s = %s\n', var_alias, expression);
                    end
                elseif obj.solver_method == obj.DEF_SOLVER_FSOLVE                    
                    output_aliases = obj.gi.getAliasById(obj.var_matched_ids);
                    for output_idx = 1:length(obj.scc)
                        expression = char(obj.expressions(output_idx));
                        fprintf('%s: 0 = %s\n', output_aliases{output_idx}, expression);
                    end
                end
                fprintf('--- SCC end -----------------\n');
            end
        end
        
    end
    
end

