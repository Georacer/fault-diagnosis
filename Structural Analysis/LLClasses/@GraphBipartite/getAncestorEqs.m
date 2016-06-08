function [ tally, matching ] = getAncestorEqs( gh, id, tally, matching )
%GETPARENTEQS Find all the parent equations of a variable or equation
%   Usable only in a directed subgraph

% debug = true;
debug = false;

if nargin <3
    tally = [];
    matching = [];
end

% idArray = [];

% if gh.isEquation(id)
%     tally(end+1) = id; % Add this equation to the visited list
%     if debug fprintf('getAncestorEqs: Sourcing parent variables of %s\n',gh.getAliasById(id)); end
%     parentVars = gh.getParentVars(id);
%     for i=parentVars
%         if debug fprintf('getAncestorEqs: Sourcing parent equation of variable %s\n',gh.getAliasById(i)); end
%         [newIds, tally] = gh.getAncestorEqs(i, tally);
%         idArray = unique([idArray newIds]);
%     end

if gh.isEquation(id)
    if debug fprintf('getAncestorEqs: Sourcing parent variables of %s\n',gh.getAliasById(id)); end
    parentVars = gh.getParentVars(id);
    for i=parentVars
        if debug fprintf('getAncestorEqs: Sourcing parent equation of variable %s\n',gh.getAliasById(i)); end
        [tally, matching] = gh.getAncestorEqs(i, tally, matching);
    end
    
% elseif gh.isVariable(id)
%     if gh.isMatched(id)
%         % Find which equation gh variable is matched to
%         varIndex = gh.getIndexById(id);
%         equId = gh.variables(varIndex).matchedTo;
%         if ~any(ismember(tally,equId)) % Check if this equation has been previously visited
%             if debug fprintf('getAncestorEqs: Adding equation %s and sourcing its ancestors.\n',gh.getAliasById(equId)); end
%             [newIds, tally] = gh.getAncestorEqs(equId, tally);
%             idArray = unique([equId newIds]);
%         end
%     end
    
elseif gh.isVariable(id)
    if gh.isMatched(id)
        % Find which equation gh variable is matched to
        varIndex = gh.getIndexById(id);
        equId = gh.variables(varIndex).matchedTo;
        if ~any(ismember(tally,equId)) % Check if this equation has been previously visited
            if debug fprintf('getAncestorEqs: Adding equation %s and sourcing its ancestors.\n',gh.getAliasById(equId)); end
            tally(end+1) = equId;
            matching(end+1) = gh.getEdgeIdByVertices(equId,id);
            [tally, matching] = gh.getAncestorEqs(equId, tally, matching);
        end
    end
    
else
    error('Unknown id %d\n',id);
end

end

