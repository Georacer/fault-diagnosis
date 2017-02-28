function [ Mvalid ] = matchBBILP( matcher )
%MATCHVALID Find valid residuals in provided MTES
%   Uses Branch-and-Bound Integer Linear Programming

debug = false;
% debug = true;

gi = matcher.gi;

C = BBILPChild(gi);

C.findMatching();
if C.isMatchingValid() %
    MValid = C.matching;
    return;
end

activeSet = {C};
setCosts = [C.cost];
U = inf;
L = -inf;
currentBest = [];

while (~isempty(activeSet))
    
    probIndex = chooseProblem(setCosts); % Choose a subproblem
    
    lb = setCosts(probIndex); % Pop the cost
    setCosts(probIndex) = [];
    
    subprob = activeSet{probIndex}; % Pop the subproblem
    activeSet(probIndex) = []; % 
    
    if lb>U % Kill the child
        % nop
    else
        if subprob.isMatcingValid() % Test if solution is complete
            U = lb;
            currentBest = subprob.matching;
        else % Break into children and go on
            cycles = findCycles(subprob);
            offendingEdges = getCycleEdges(cycles);
            for i=1:length(offendingEdges)
                childProb = subProb;
                childProb.prohibitEdge(offendingEdges(i));
                childProb.findMatching();
                activeSet{end+1} = childProb;
                setCosts(end+1) = childProb.cost;
            end
        end
    end
    
    
end

end

function index = chooseProblem(costlist)
    [~, index] = min(costlist);
end