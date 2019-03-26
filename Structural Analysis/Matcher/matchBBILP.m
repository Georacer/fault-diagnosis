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
p.addParameter('exitAtFirstValid', true, @islogical);

p.parse(matcher, varargin{:});
opts = p.Results;
branchMethod = opts.branchMethod;
exitAtFirstValid = opts.exitAtFirstValid;

gi = matcher.gi;

C = BBILPChild(gi);
past_children = containers.Map; % A tally of which children have already been examined

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
    
    % Pop a child
    
    lb = setCosts(probIndex); % Pop the cost
    setCosts(probIndex) = [];
    subprob = activeSet{probIndex}; % Pop the subproblem
    activeSet(probIndex) = []; %
    
    if debug
        fprintf('matchBBILP: Popped child [');
        fprintf('%d, ',subprob.edgesInhibited);
        fprintf('] with cost %d\n',lb);
    end
    
    % Create children
    branching_edges = subprob.get_branching_edges();
    for i=1:length(branching_edges)
        current_restriction = branching_edges{i};
        % Check if this child has already been created
        restriction = unique([subprob.edgesInhibited current_restriction]);  % This is likely unnecessary:
        % the subproblem cannot have a branching edge already inhibited, because inhibited edges cannot partake in a
        % matching, hance they cannot be thrown as violating validity
        key = num2str(restriction);
        if ~past_children.isKey(key)
            past_children(key) = true;
            childProb = subprob.createChild;
            childProb.prohibitEdges(restriction);
            childProb.findMatching();
            if debug
                fprintf('matchBBILP: Produced child with matching [ ');
                fprintf('%d, ', childProb.matching);
                fprintf('] and restricted edges [ ');
                fprintf('%d, ', restriction);
                fprintf('] ');
            end
            lb = childProb.cost; % Extract the lower-bound cost
            if lb>=U % if cost is higher than current best, kill the child
                if debug; fprintf('but cost not lower than current upper bound\n'); end
            else % Else examine the child
                examinations = examinations+1;
                if childProb.isMatchingValid() % if solution is valid, store it
                    if debug; fprintf('and found a valid solution, setting upper bound\n'); end
                    U = lb;
                    Mvalid = childProb.matching;
                    if exitAtFirstValid
                        break;
                    end
                else % Else store the child and proceed to next
                    activeSet{end+1} = childProb;
                    setCosts(end+1) = childProb.cost;
                    if debug; fprintf('and pushed it\n'); end
                end
            end
        else
            if debug
                fprintf('matchBBILP: Child with restriction [ ');
                fprintf('%d, ', restriction);
                fprintf('] already exists\n');
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