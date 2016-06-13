function [ edge_sequence ] = parseMatchingNoCycles( gh )
%PARSEMATCHINGNOCYCLES Feasible matching evaluation order
%   Given a matched GraphBipartite object, extract a feasible evaluation
%   order in the form of an edge ID list, provided that no cycles are
%   needed

edge_sequence = [];

vars_known = [gh.getVarIdByProperty('isInput') gh.getVarIdByProperty('isMeasured')];
edges_matched = gh.getEdgeIdByProperty('isMatched');
equations_matched = gh.getEquations(edges_matched); % All the matched equations
variables_matched = gh.getVariables(edges_matched); % All the matched variables

bins = ones(size(equations_matched));
for i=1:length(bins)
    bins(i) = length(gh.getEdgeIdArray(equations_matched(i)));
end

while ~isempty(vars_known)
    % Pop the next known variable
    v = vars_known(1);
    vars_known(1) = [];
    
    % Find which equations need it and subtract their unknowns
    equIds = gh.getEquations(v);
    bin_indices = find(ismember(equations_matched,equIds));
    bins(bin_indices) = bins(bin_indices)-1;
    
    % Check if any of them can be solved
    ripe_equation_indices = find(bins==1);
    for i=ripe_equation_indices
        edge_sequence = [edge_sequence edges_matched(i)];
        vars_known = [vars_known variables_matched(i)];
    end
    % and then drop them below threshold
    bins(ripe_equation_indices) = 0;    
       
end


end

