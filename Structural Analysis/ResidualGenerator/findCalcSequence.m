function [ solutionOrder ] = findCalcSequence( digraph )
%PRINTMATCHING Print the calculation sequence of a directed graph
%   In a friendly way that will allow later the extraction of the
%   analytical calculation sequence
%
%   OUTPUT: Equation IDs, in the order they should be evaluated. Each line
%   is an SCC


debug = true;

%% Checks

matchedVars = digraph.getVarIdByProperty('isMatched');
if length(matchedVars)~=digraph.graph.numVars
    error('Not all variables are matched');
end
matchedEqs = digraph.getEquIdByProperty('isMatched');
if length(matchedEqs)~=length(matchedVars)
    error('# of matched equations not equal to # of matched variables');
end

%% Get the residual generator equations

RGids = findResGenerators(digraph, true);
if isempty(RGids)
    error('No residual generators available');
end

% It should normally be only 1
if length(RGids)>1
    error('I expected only 1 residual generator');
end

%% Find all ancestor equations in DFS order

ancestorEqIds = digraph.getAncestorEqs(RGids);
ancestorEqIds = setdiff(ancestorEqIds,RGids); % Remove the residual from the calculation order
ancestorEqIds = ancestorEqIds(end:-1:1); % Reverse order to start from known inputs

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
    if ~ismember(SCCIds(logical(equIndices)), ancestorEqIds) % Test if these equations actually affect the residual
        if debug
            fprintf('printMatching: Dropping equations irrelevant to the residual: ');
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

solutionOrder(end+1) = {RGids};

% Print solution order
for i=1:length(solutionOrder)
    s = sprintf('%d, ', solutionOrder{i});
    fprintf('%s\n', s(1:end-1));
end

end

