function [ evaluators_cell ] = create_evaluators( gi, digraph, solution_order, dictionary, dt )
%CREATE_EVALUATORS Convert the solution order into Evaluator objets
%   Detailed explanation goes here

debug = false;
% debug = true;

if nargin < 4
    dt = 0.01;
end

sgg = SubgraphGenerator(digraph);

evaluators_cell = {};
for i=1:length(solution_order)
    scc = solution_order{i};
    sub_digraph = sgg.buildSubgraph(scc);
    if any(gi.getPropertyById(scc,'isDynamic'))
        if length(scc)==1  % Build a Differentiator
            new_evaluator = Differentiator(gi, sub_digraph, scc, dictionary, dt);
            if (debug)
                fprintf('create_evaluators: Created a new Differentiator for equations ');
                fprintf('%d,', new_evaluator.scc);
                fprintf('\n');
            end
        else  % This is a non-trivial SCC, build a DAESolver
            new_evaluator = DAESolver(gi, sub_digraph, scc, dictionary, dt);
            if (debug)
                fprintf('create_evaluators: Created a new DAESolver for equations ');
                fprintf('%d,', new_evaluator.scc);
                fprintf('\n');
            end
        end
    else
        try
            new_evaluator = Evaluator(gi, sub_digraph, scc, dictionary);
            if (debug)
                fprintf('create_evaluators: Created a new Evaluator for equations ');
                fprintf('%d,', new_evaluator.scc);
                fprintf('\n');
            end
        catch e
            new_evaluator = [];  % MATLAB could not solve the evaluator expression
        end
    end
    evaluators_cell(end+1) = {new_evaluator};
    
end


end

