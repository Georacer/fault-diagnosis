function [ idArray ] = getAncestorEqs( gh, id )
%GETPARENTEQS Find all the parent equations of a variable or equation
%   Usable only in a directed subgraph

% debug = true;
debug = false;

idArray = [];

if gh.isEquation(id)
    if debug fprintf('getAncestorEqs: Sourcing parent variables of %s\n',gh.getAliasById(id)); end
    parentVars = gh.getParentVars(id);
    for i=parentVars
        if debug fprintf('getAncestorEqs: Sourcing parent equation of variable %s\n',gh.getAliasById(i)); end
        idArray = unique([idArray gh.getAncestorEqs(i)]);
    end
    
elseif gh.isVariable(id)
    if gh.isMatched(id)
        % Find which equation gh variable is matched to
        varIndex = gh.getIndexById(id);
        equId = gh.variables(varIndex).matchedTo;
        if debug fprintf('getAncestorEqs: Adding equation %s and sourcing its ancestors.\n',gh.getAliasById(equId)); end
        idArray = unique([idArray equId gh.getAncestorEqs(equId)]);
    end
else
    error('Unknown id %d\n',id);
end

id = unique(id);

end

