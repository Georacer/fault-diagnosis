function [ varId ] = getParentVars( gh, id )
%GETPARENTVARS Return variables directly used for calculation
%   Detailed explanation goes here

% debug = true;
debug = false;

varId = [];
    
if gh.isVariable(id)
    error('getParentVars function only applies to equations\n');
end

eqIndex = gh.getIndexById(id);

if ~gh.isMatched(id)
    warning('Requested parent variables of an unmatched equation\n');
else
    
    edgeIds = gh.equations(eqIndex).edgeIdArray;
    for edgeIndex = gh.getIndexById(edgeIds);
        if ~gh.edges(edgeIndex).isMatched
            if debug fprintf('Adding variable %s\n',gh.getAliasById(gh.edges(edgeIndex).varId)); end
            varId = [varId gh.edges(edgeIndex).varId];
        end
    end
    
    if debug 
        fprintf('getParentVars: The parent variables of %s are %d: ',gh.getAliasById(id), length(varId));
        for i=1:length(varId)
            fprintf('%s, ',gh.getAliasById(varId(i)));
        end
        fprintf('\n');
    end
end

end

