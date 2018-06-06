function [ ids ] = findResGenerators( gi, faultsOnly )
%FINDRESGENERATORS Find unmatched constraints which can generate residuals
%   Eligible constraints are those which have all of their contributing variables matched
%   If faultsOnly=true, then at least one of the contributing equation or the residual generator itself must be
%   faultable

debug = true;

if nargin<2
    faultsOnly=false;
end

freeEqs = gi.getEquIdByProperty('isMatched', false);
ids = [];

if isempty(freeEqs)
    warning('No unmatched equations available');
end

for equId = freeEqs
    parentEqs = gi.getAncestorEqs(equId); % Get all parent equations
    varIds = gi.getVariables(parentEqs); % Get all related variables
    
    if ~isempty(varIds) % This equation doesn't rely on any other variable 
        allMatched = all(gi.isMatched(varIds)); % Find which of the variables are matched
        if ~allMatched % This residual doesn't have all of its variables matched
            if debug; fprintf('Found a residual with no complete matching\n'); end
            continue
        end
    end
    
    if faultsOnly
        anyFaultable = any([gi.isFaultable([equId parentEqs])]);
        if ~anyFaultable
            if debug; fprintf('found a residual which doesnt cover any faults\n'); end
            continue
        end
    end
    
    ids(end+1) = equId;
    
end

end

