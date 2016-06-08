function M = matchWeightedElimination( gh )
%MATCHWEIGHTEDELIMINATION Summary of this function goes here
%   Detailed explanation goes here


debug = true;

residualIdArray = [];

% Build the matching set
M = [];
w = [];

% Find all unmatched constraints with 1 unknown variable
Mstar = [];
wstar = [];
CU = gh.getEquIdByProperty('isMatched', false);

if debug
    fprintf('*** Initially found %d unmatched constraints\n',length(CU));
end

for equId = CU
    vars = gh.getVariablesUnknown(equId);
    if length(vars)==1
        edgeId = gh.getEdgeIdByVertices(equId,vars);
        if gh.isMatchable(edgeId)
            edgeIndex = gh.getIndexById(edgeId);
            Mstar(end+1) = edgeId;
            wstar(end+1) = gh.edges(edgeIndex).weight;
        end
    end
end

% Sort in ascending order
[wstar, p] = sort(wstar);
Mstar = Mstar(p);

if debug
    fprintf('*** Initial matching candidates: ');
    disp(Mstar);
    disp(wstar);
end

% Main loop
while ~isempty(Mstar)
    
    if debug
        fprintf('*** Another elimination loop: Size of Mstar=%d\n',length(Mstar));
    end
    
    % Add the cheapest edge to the matching set
    m = Mstar(1);
    M(end+1) = m;
    w(end+1) = wstar(1);
    edgeInd = gh.getIndexById(m);
    equId = gh.edges(edgeInd).equId;
    varId = gh.edges(edgeInd).varId;
    equInd = gh.getIndexById(equId);
    varInd = gh.getIndexById(varId);
    gh.setMatched(m);
    gh.setMatched(varId);
    gh.variables(varInd).matchedTo = equId;
    gh.setMatched(equId);
    gh.equations(equInd).matchedTo = varId;
    CU = setdiff(CU, equId);
    gh.setKnown(varId);
    
    % Remove it from the candidate set
    Mstar(1) = [];
    wstar(1) = [];
    
    % Remove edges with common variable from candidate set
    commonEdges = zeros(size(Mstar));
    k=1;
    for id = Mstar
        edgeIndex = gh.getIndexById(id);
        if gh.edges(edgeIndex).varId == varId
            commonEdges(k) = 1;
        end
        k = k+1;
    end
    Mstar(logical(commonEdges)) = [];
    wstar(logical(commonEdges)) = [];
    
    % Add new candidate edges
    for equId = CU
        vars = gh.getVariablesUnknown(equId);
        if length(vars)==1
            edgeId = gh.getEdgeIdByVertices(equId,vars);
            if gh.isMatchable(edgeId)
                edgeIndex = gh.getIndexById(edgeId);
                Mstar(end+1) = edgeId;
                wstar(end+1) = gh.edges(edgeIndex).weight;
            end
        end
    end
    
    % Sort in ascending order
    [wstar, p] = sort(wstar);
    Mstar = Mstar(p);
    
end

%% Find residual generators
for equId = CU
    vars = gh.getVariablesUnknown(equId);
    if isempty(vars)
        residualIdArray(end+1) = equId;
        gh.setMatched(equId);
        eqIndex = gh.getIndexById(equId);
        gh.equations(eqIndex).isResGenerator = true;
        gh.addResidual(equId);
    end
end

%% Check matching characteristics

matchedEqs = length(gh.getEquIdByProperty('isMatched',true));

matchedVars = length(gh.getVarIdByProperty('isMatched',true));

numResiduals = length(residualIdArray);

fprintf('Matching results:\n');
fprintf('%d/%d variables matched\n',matchedVars,gh.numVars);
fprintf('%d residuals generated\n',numResiduals);
fprintf('%d equations used\n',matchedEqs);


end

