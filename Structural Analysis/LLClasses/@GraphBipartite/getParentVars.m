function [ varId ] = getParentVars( this, id )
%GETPARENTVARS Return variables directly used for calculation
%   Detailed explanation goes here

% debug = true;
debug = false;

varId = [];
    
if this.isVariable(id)
    error('getParentVars function only applies to equations\n');
end

eqIndex = this.getEqIndexById(id);
if ~this.equationArray(eqIndex).isMatched
    warning('Requested parent variables of an unmatched equation\n');
else
    for i=1:this.equationArray(eqIndex).numVars
        if ~this.equationArray(eqIndex).variableArray(i).isMatched
            if debug fprintf('Adding variable %s\n',this.equationArray(eqIndex).variableArray(i).alias); end
            varId = [varId this.equationArray(eqIndex).variableArray(i).id];
        end
    end
    if debug 
        fprintf('The parent variables of %s are %d: ',this.getAliasById(id), length(varId));
        for i=1:length(varId)
            fprintf('%s, ',this.getAliasById(varId(i)));
        end
        fprintf('\n');
    end
end

end

