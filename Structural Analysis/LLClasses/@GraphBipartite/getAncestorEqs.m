function [ idArray ] = getAncestorEqs( this, id )
%GETPARENTEQS Find all the parent equations of a variable or equation
%   Usable only in a directed subgraph

% debug = true;
debug = false;

idArray = [];

if this.isEquation(id)
    if debug fprintf('Sourcing parent variables of %s\n',this.getAliasById(id)); end
    parentVars = this.getParentVars(id);
    for i=parentVars
        if debug fprintf('Sourcing parent equation of variable %s\n',this.getAliasById(i)); end
        idArray = unique([idArray this.getAncestorEqs(i)]);
    end
    
elseif this.isVariable(id)
    % Find which equation this variable is matched to
    for i=1:this.numEqs
        for j=1:this.equationArray(i).numVars
            if (this.equationArray(i).variableArray(j).id == id) && (this.equationArray(i).variableArray(j).isMatched)
                if debug fprintf('Adding equation %s and sourcing its ancestors.\n',this.equationArray(i).alias); end
                % Return this equation id and run the recursion for its
                % parent variables
                idArray = unique([idArray this.equationArray(i).id this.getAncestorEqs(this.equationArray(i).id)]);
            end
        end
    end
    
else
    error('Unknown id %d\n',id);
end

id = unique(id);

end

