function [ Mvalid ] = matchBBILP( matcher, varargin )
%MATCHVALID Find valid residuals in provided MTES
%   Uses Branch-and-Bound Integer Linear Programming

debug = false;
% debug = true;

if debug
    if ~evalin('base','exist(''examinations'')')
        evalin('base','examinations=0');
    end
end

p = inputParser;

p.addRequired('matcher',@(x) true);
p.addParameter('branchMethod','cheap',@isstr);

p.parse(matcher, varargin{:});
opts = p.Results;
branchMethod = opts.branchMethod;

gi = matcher.gi;

C = BBILPChild(gi);

C.findMatching();
% C.matching
if C.isMatchingValid() %
    if debug; fprintf('matchBBILP: initial relaxed solution was valid; ending\n'); end
    Mvalid = C.matching;
    if debug
        fprintf('matchBBILP: Final solution: [');
        fprintf('%d ',Mvalid);
        fprintf('], with cost %d\n',C.cost);
        evalin('base',sprintf('examinations(end+1) = %d', 0))
    end
    return;
end
if C.cost==inf % Even the relaxed problem does not have a solution    
    if debug; fprintf('matchBBILP: initial relaxed problem does not have an solution; ending\n'); end
    Mvalid = [];
    return;
end

activeSet = {C};
setCosts = [C.cost];
U = inf;
L = -inf;
Mvalid = [];

examinations = 0;

while (~isempty(activeSet))
    
    
    probIndex = chooseProblem(setCosts,branchMethod); % Choose a subproblem
    lb = setCosts(probIndex); % Pop the cost
    if debug; fprintf('matchBBILP: Popping child with cost %d\n',lb); end
    setCosts(probIndex) = [];
    
    subprob = activeSet{probIndex}; % Pop the subproblem
    activeSet(probIndex) = []; % 
    
    if lb>=U % Kill the child
    if debug; fprintf('matchBBILP: Child cost not lower than current upper bound\n'); end
    else
        examinations = examinations+1;
        if subprob.isMatchingValid() % Test if solution is complete
            if debug; fprintf('matchBBILP: Found a valid solution, setting upper bound\n'); end
            U = lb;
            Mvalid = subprob.matching;
        else % Break into children and go on
            edgeCandidates = subprob.getOffendingEdges;
            if debug; fprintf('matchBBILP: Producing %d children\n',length(edgeCandidates)); end
            for i=1:length(edgeCandidates)
                childProb = subprob.createChild;
                childProb.prohibitEdge(edgeCandidates(i));
                childProb.findMatching();
%                 childProb.matching
                activeSet{end+1} = childProb;
                setCosts(end+1) = childProb.cost;
            end
        end
    end

end

if debug
    fprintf('matchBBILP: Final solution: [');
    fprintf('%d ',Mvalid);
    fprintf('], with cost %d\n',U);
    fprintf('Found after %d examinations\n',examinations);
    evalin('base',sprintf('examinations(end+1) = %d',examinations));
end

end

function index = chooseProblem(costlist,branchMethod)
    switch branchMethod
        case 'cheap'
            [~, index] = min(costlist);
        case 'BFS'
            index = 1;
        case 'DFS'
            index = length(costlist);
    end
end

% function edgeIds = getCycleEdges(cycles)
%     edgeIds = [];
%     for i=1:length(cycles)
%         edgeIds = [edgeIds cycles{i}];
%     end
%     edgeIds = unique(edgeIds);
% end