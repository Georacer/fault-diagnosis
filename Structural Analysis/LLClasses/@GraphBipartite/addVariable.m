function [respAdded, id] = addVariable( this, id,alias,varProps,name,description )
%ADDVARIABLE Summary of this function goes here
%   Detailed explanation goes here

respAdded = false;

l1 = length(this.variables);
l2 = length(this.variableAliasArray);
l3 = length(this.variableIdArray);

if (l1==l2) && (l2==l3)

    % Lookup the variable
    varId = this.getVarIdByAlias(alias);

    if isempty(varId) % This variable was not yet met

        if isempty(id)
            id = this.idProvider.giveID();
        end

        tempVar = Variable(id,alias); % Create a new variable object
        tempVar.isKnown = varProps.isKnown;
        tempVar.isMeasured = varProps.isMeasured;
        tempVar.isInput = varProps.isInput;
        tempVar.isOutput = varProps.isOutput;
        tempVar.isResidual = varProps.isResidual;
        tempVar.isMatched = varProps.isMatched;
        
        this.variables(end+1) = tempVar;
        this.variableAliasArray{end+1} = alias;
        this.variableIdArray(end+1) = id;
        this.variableIdToIndexArray(id) = l1+1;
        
        respAdded = true;
    else
        this.setPropertyOR(varId,'isKnown',varProps.isKnown);
        this.setPropertyOR(varId,'isMeasured',varProps.isMeasured);
        this.setPropertyOR(varId,'isInput',varProps.isInput);
        this.setPropertyOR(varId,'isOutput',varProps.isOutput);
        this.setPropertyOR(varId,'isMatched',varProps.isMatched);
        id = varId;
    end
else
    error('Inconsistent variable arrays sizes');
end


end

