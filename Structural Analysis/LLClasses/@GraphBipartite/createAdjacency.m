function createAdjacency(gh)
% Create the graph adjacency matrix
numVars = gh.numVars;
numEqs = gh.numEqs;
numEls = numVars + numEqs;
adjacency = zeros(numEls,numEls);
E = gh.getEdges();

for i=1:size(E,1)
    id1 = E(i,1);
    id2 = E(i,2);
    if gh.isVariable(id1) % V2E edge
        varIndex = gh.getIndexById(id1);
        equIndex = gh.getIndexById(id2);
        adjacency(varIndex,numVars+equIndex) = 1;
    else% E2V edge
        equIndex = gh.getIndexById(id1);
        varIndex = gh.getIndexById(id2);
        adjacency(numVars+equIndex,varIndex) = E(i,3);
    end
end

gh.adjacency = Adjacency(adjacency,gh.equationAliasArray,gh.equationIdArray,gh.variableAliasArray,gh.variableIdArray);

end