function M = weightedElimination( mh, varargin )
%WEIGHTEDELIMINATION Summary of this function goes here
%   Detailed explanation goes here

obeyCausality = true;

p = inputParser;

p.addRequired('mh',@(x) true);
p.addParameter('maxRank',inf,@(x) floor(x)==x);
p.addParameter('maxMatchings',inf,@(x) floor(x)==x);

p.parse(mh, varargin{:});
opts = p.Results;

maxRankAllowed = opts.maxRank; % The highest rank which matching is allowed to reach
maxMatchingsAllowed = opts.maxMatchings; % Maximum number of matchings allowed to be performed

debug = true;
% debug = false;

rankArray = zeros(1,max(mh.gi.reg.varIdArray)); % We will need at most max(varId) ids

% Build the matching set
M = [];
w = [];

% Overall rank variable
overallRank = 0;

% Find all unmatched constraints with 1 unknown variable
Mstar = [];
wstar = [];
CU = mh.gi.getEquIdByProperty('isMatched', false);

if debug
    fprintf('*** Initially found %d unmatched constraints\n',length(CU));
end

for equId = CU
    UKvarIds = mh.gi.getVariablesUnknown(equId);
    UMvarIds = UKvarIds(~mh.gi.isMatched(UKvarIds));
    if length(UMvarIds)==1 % Only one uknown variable unmatched
        edgeId = mh.gi.getEdgeIdByVertices(equId,UMvarIds);
        if mh.isMatchable(edgeId)
            Mstar(end+1) = edgeId;
            wstar(end+1) = mh.gi.getEdgeWeight(edgeId);
        end
    end
end

% Sort in ascending order
[wstar, p] = sort(wstar);
Mstar = Mstar(p);

if debug
    fprintf('*** Initial matching candidates:\n');
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
    edgeInd = mh.gi.getIndexById(m);
    equId = mh.gi.graph.edges(edgeInd).equId;
    varId = mh.gi.graph.edges(edgeInd).varId;
    equInd = mh.gi.getIndexById(equId);
    varInd = mh.gi.getIndexById(varId);
        
    % Check if the matching does not exceed the maximum rank allowed
    otherVarIds = setdiff(mh.gi.getVariables(equId),varId);
    maxRank = 0;
    if ~isempty(otherVarIds)
        for id = otherVarIds
            rank = rankArray(id);
%             index = mh.gi.getIndexById(id);
%             rank = mh.gi.variables(index).rank;
            if rank>maxRank
                maxRank=rank;
            end
        end
    end
    if (maxRank+1)>maxRankAllowed
        fprintf('***Reached maximum allowed rank\n');
        break;
    end
    rankArray(equId) = maxRank+1;
    rankArray(varId) = maxRank+1;
%     mh.equations(equInd).rank = maxRank+1;
%     mh.variables(varInd).rank = maxRank+1; 
    
    M(end+1) = m;
    w(end+1) = wstar(1);
    if debug; fprintf('WeightedElimination: Matching edge %d\n',m); end
    mh.gi.setMatched(m);
    CU = setdiff(CU, equId);
%     mh.gi.setKnown(varId);
    
    % Remove it from the candidate set
    Mstar(1) = [];
    wstar(1) = [];
    
    % Remove edges with common variable from candidate set
    commonEdges = zeros(size(Mstar));
    k=1;
    for id = Mstar
        edgeIndex = mh.gi.getIndexById(id);
        if mh.gi.graph.edges(edgeIndex).varId == varId
            commonEdges(k) = 1;
        end
        k = k+1;
    end
    Mstar(logical(commonEdges)) = [];
    wstar(logical(commonEdges)) = [];
    
    % Add new candidate edges
    for equId = CU
        vars = mh.gi.getVariablesUnknown(equId);
        if length(vars)==1
            edgeId = mh.gi.getEdgeIdByVertices(equId,vars);
            if mh.isMatchable(edgeId)
                Mstar(end+1) = edgeId;
                wstar(end+1) = mh.gi.getEdgeWeight(edgeId);
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

%% Add residuals where posible

resGenIds = findResGenerators(mh.gi);
mh.gi.addResidual(resGenIds);

%% Check matching characteristics

matchedEqs = length(mh.gi.getEquIdByProperty('isMatched',true));
matchedVars = length(mh.gi.getVarIdByProperty('isMatched',true));
matchedEdges = length(mh.gi.getEdgeIdByProperty('isMatched',true));

numResiduals = length(resGenIds);

fprintf('Matching results:\n');
fprintf('Length of returned matching set: %d\n',length(M));
fprintf('%d/%d variables matched\n',matchedVars,mh.gi.graph.numVars);
fprintf('%d residuals generated\n',numResiduals);
fprintf('%d/%d equations matched\n',matchedEqs,mh.gi.graph.numEqs);
fprintf('%d/%d edges matched\n',matchedEdges,mh.gi.graph.numEdges);
fprintf('Maximum rank reached: %d\n',overallRank);


end

