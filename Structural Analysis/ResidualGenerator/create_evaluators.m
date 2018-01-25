function [ evaluators_cell ] = create_evaluators( gi, digraph, solution_order )
%CREATE_EVALUATORS Convert the solution order into Evaluator objets
%   Detailed explanation goes here

evaluators_cell = {};
for i=1:length(solution_order)
    scc = solution_order{i};
    if length(scc)==1 && gi.getPropertyById(scc,'isDynamic')
        new_evaluator = Differentiator(gi, digraph, scc);
        new_evaluator.set_dt(0.01);  % Set the differentiation/integration time dt
    else
        new_evaluator = Evaluator(gi, digraph, scc);
    end
    evaluators_cell(end+1) = {new_evaluator};
    
end


end

