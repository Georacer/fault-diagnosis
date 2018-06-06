function [ graphs ] = getDisconnected( gi )
%GETDISCONNECTED Find all the disconnected subgraphs of the input graph
%   Uses the Tarjan algorithm. Very useful to fragment a matching problem
%   into smaller problems
%   INPUTS:
%   gi: The initial graph interface object
%   OUTPUTS:
%   graphs: An array of GraphInterface objects, disjoint from each other
%   NOTE: The returned graphs may have common known variables, which do not
%   prevent the problem to become of smaller complexity

% Create a new graph with only unknown variables
sg = SubgraphGenerator(gi);
gi_u = sg.buildSubgraph(gi.getEquations(), 'PruneKnown', true);

numVars = gi_u.graph.numVars;
numEqs = gi_u.graph.numEqs;
V2E = gi_u.adjacency.V2E;  % Get the Variable->Equation matrix
% Use it to build the weak biadjacency matrix
BDw = [zeros(numVars) V2E;...
       V2E' zeros(numEqs)];

equIds = gi_u.getEquations();
varIds = gi_u.getVariables();

% Find the disconnected subgraphs
sccs = tarjan2(BDw);  % Find the strongly connected components

% If the original graph is the only scc
if length(sccs)==1
    graphs = {gi};
    return;
else
    allIds = [varIds equIds];
    sccsEquIds = cell(1,length(sccs));  % Preallocate the equation ids of each subgraph
    
    for i=1:length(sccs)
        sccIds = allIds(sccs{i});  % Find all the ids of this scc
        equIndices = gi_u.isEquation(sccIds);  % Find which of them are equations
        if ~any(equIndices) % This scc is a single variable
            warning('An scc found which was a single variable');
        end
        sccEquIds{i} = sccIds(logical(equIndices));
    end
    
    % Build a new graph for each scc
    graphs = cell(1,length(sccs));
    for i=1:length(graphs)
        graphs{i} = sg.buildSubgraph(sccEquIds{i}, 'postfix', sprintf('_%d',i)); % Let the original variables be re-introduced
    end
end

end

