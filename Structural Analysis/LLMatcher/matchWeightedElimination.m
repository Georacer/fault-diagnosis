function M = matchWeightedElimination( gh, varargin )
%MATCHWEIGHTEDELIMINATION Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

p.addRequired('gh',@(x) true);
p.addParameter('maxRank',inf,@(x) floor(x)==x);
p.addParameter('maxMatchings',inf,@(x) floor(x)==x);

p.parse(gh, varargin{:});
opts = p.Results;

maxRankAllowed = opts.maxRank; % The highest rank which matching is allowed to reach
maxMatchingsAllowed = opts.maxMatchings; % Maximum number of matchings allowed to be performed

debug = true;

residualIdArray = [];

% Build the matching set
M = [];
w = [];

% Overall rank variable
overallRank = 0;

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
    edgeInd = gh.getIndexById(m);
    equId = gh.edges(edgeInd).equId;
    varId = gh.edges(edgeInd).varId;
    equInd = gh.getIndexById(equId);
    varInd = gh.getIndexById(varId);
        
    % Check if the matching does not exceed the maximum rank allowed
    otherVarIds = setdiff(gh.getVariables(equId),varId);
    maxRank = 0;
    if ~isempty(otherVarIds)
        for id = otherVarIds
            index = gh.getIndexById(id);
            rank = gh.variables(index).rank;
            if rank>maxRank
                maxRank=rank;
            end
        end
    end
    if (maxRank+1)>maxRankAllowed
        fprintf('***Reached maximum allowed rank\n');
        break;
    end
    gh.equations(equInd).rank = maxRank+1;
    gh.variables(varInd).rank = maxRank+1; 
    
    M(end+1) = m;
    w(end+1) = wstar(1);
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
    
    if (maxRank+1)>overallRank
        overallRank=maxRank+1;
    end
    
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
fprintf('Maximum rank reached: %d\n',overallRank);


end

