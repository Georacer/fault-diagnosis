function [ solutionOrder ] = findCalcSequence( digraph, varargin )
%PRINTMATCHING find the calculation sequence of a directed graph
%
%   CAUTION: Supposes that the graph only contains unknown variables. No
%   input variables must exist
%
%   OUTPUT: Equation IDs, in the order they should be evaluated. Each line
%   is an SCC


debug = true;

p = inputParser;

p.addRequired('digraph',@(x) true);
p.addParameter('asResGenerator', false);

p.parse(digraph, varargin{:});
opts = p.Results;

%% Checks

unknown_vars = digraph.getVarIdByProperty('isKnown',false);
if isempty(unknown_vars)
    unsolvable_vars_exist = false;
else
    unsolvable_vars_exist = digraph.isMatched(unknown_vars);
end
if unsolvable_vars_exist
    error('Unknown yet unmatched variables exist');
end
matchedVars = digraph.getVarIdByProperty('isMatched');
matchedEqs = digraph.getEquIdByProperty('isMatched');
if length(matchedEqs)~=length(matchedVars)
    error('# of matched equations not equal to # of matched variables');
end

%% If this digraph constructs a residual generator

if opts.asResGenerator
    
    % Get the residual generator equations
    
    RGids = findResGenerators(digraph, true);
    if isempty(RGids)
        error('No residual generators available');
    end
    
    % It should normally be only 1
    if length(RGids)>1
        error('I expected only 1 residual generator');
    end
    
    % Find all ancestor equations in DFS order
    
    relevantEqIds = digraph.getAncestorEqs(RGids);
    relevantEqIds = setdiff(relevantEqIds,RGids); % Remove the residual from the calculation order
    relevantEqIds = relevantEqIds(end:-1:1); % Reverse order to start from known inputs

else
    relevantEqIds = digraph.getEquations();
end

%% Generate the fully ordered SCC list

% Extract all SCCs
SCCs = tarjan2(digraph.adjacency.BD);
allIds = [digraph.reg.varIdArray digraph.reg.equIdArray];
SCCsEquIds = {};
SCCsVarIds = {};
SCCsMatchedVarIds = {};
% Keep only equation IDs
for i=1:length(SCCs)
    SCCIds = allIds(SCCs{i});
    equIndices = digraph.isEquation(SCCIds);
    if ~any(equIndices) % This SCC is a single variable
        continue
    end
    if ~ismember(SCCIds(logical(equIndices)), relevantEqIds) % Test if these equations actually affect the residual
        if debug
            fprintf('findCalcSequence: Dropping equations irrelevant to the residual: ');
            fprintf('%d,', SCCIds(logical(equIndices)) );
            fprintf('\n');
        end
        continue
    end
    SCCsEquIds{end+1} = SCCIds(logical(equIndices));
    SCCsVarIds{end+1} = digraph.getVariables(SCCsEquIds{end});
    SCCsMatchedVarIds{end+1} = digraph.getMatchedVars(SCCsEquIds{end});
end

%% Propagate knowledge from inputs to outputs

% Now that each SCC is found, we can treat the graph as acyclic and
% propagate using single variable elimination

knownVarIds = [];
unusedIndices = 1:length(SCCsEquIds); % Indices to the equations SCCs cell array
% Build an active list of equations which are ready to be solved
activeList = []; % This contains indices to SCCsEquIds
for i=unusedIndices
    unknownVariables = setdiff(SCCsVarIds{i},knownVarIds);
    if isequal(unknownVariables,SCCsMatchedVarIds{i})
        activeList(end+1) = i;
    end
end
solutionOrder = {};

while ~isempty(activeList)
    unusedIndices = setdiff(unusedIndices, activeList); % Do not look in equations already in the list
    % Pop an item
    currentIndex = activeList(1);
    solutionOrder(end+1) = SCCsEquIds(currentIndex);
    activeList(1) = [];
    % Update the known variables list
    knownVarIds = [knownVarIds SCCsMatchedVarIds{currentIndex}];
    % Search for new solvable equations to populate the list
    for i=unusedIndices
        unknownVariables = setdiff(SCCsVarIds{i},knownVarIds);
        if isequal(sort(unknownVariables),sort(SCCsMatchedVarIds{i}))
            activeList(end+1) = i;
        end
    end
end

if ~isempty(unusedIndices)
    error('Not all SCCs were introduced to the calculation sequence');
end

% Add the residual generator at the end of the sequence
if opts.asResGenerator
    solutionOrder(end+1) = {RGids};
end

% Print solution order
for i=1:length(solutionOrder)
    s = sprintf('%d, ', solutionOrder{i});
    fprintf('%s\n', s(1:end-1));
end

end

