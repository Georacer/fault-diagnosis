function [ Mvalid ] = matchBBILP( matcher )
%MATCHVALID Find valid residuals in provided MTES
%   Uses Branch-and-Bound Integer Linear Programming

% debug = false;
debug = true;

gi = matcher.gi;

C = BBILPChild(gi);

C.findMatching();
if C.isMatchingValid() %
    if debug; fprintf('matchBBILP: initial relaxed solution was valid; ending\n'); end
    Mvalid = C.matching;
    if debug;
        fprintf('matchBBILP: Final solution: [');
        fprintf('%d ',Mvalid);
        fprintf('], with cost %d\n',C.cost);
    end
    return;
end

activeSet = {C};
setCosts = [C.cost];
U = inf;
L = -inf;
Mvalid = [];

while (~isempty(activeSet))
    
    probIndex = chooseProblem(setCosts); % Choose a subproblem
    lb = setCosts(probIndex); % Pop the cost
    if debug; fprintf('matchBBILP: Popping child with cost %d\n',lb); end
    setCosts(probIndex) = [];
    
    subprob = activeSet{probIndex}; % Pop the subproblem
    activeSet(probIndex) = []; % 
    
    if lb>U % Kill the child
    if debug; fprintf('matchBBILP: Child cost was higher than current upper bound\n'); end
    else
        if subprob.isMatcingValid() % Test if solution is complete
            if debug; fprintf('matchBBILP: Found a valid solution, setting upper bound\n'); end
            U = lb;
            Mvalid = subprob.matching;
        else % Break into children and go on
            cycles = findCycles(subprob);
            edgeCandidates = getCycleEdges(cycles);
            if debug; fprintf('matchBBILP: Producing %d children\n',length(edgeCandidates)); end
            for i=1:length(edgeCandidates)
                childProb = subProb;
                childProb.prohibitEdge(edgeCandidates(i));
                childProb.findMatching();
                activeSet{end+1} = childProb;
                setCosts(end+1) = childProb.cost;
            end
        end
    end

end

if debug;
    fprintf('matchBBILP: Final solution: [');
    fprintf('%d ',Mvalid);
    fprintf('], with cost %d\n',U);
end

end

function index = chooseProblem(costlist)
    [~, index] = min(costlist);
end