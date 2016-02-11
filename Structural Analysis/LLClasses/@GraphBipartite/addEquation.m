function [respAdded, id] = addEquation( this, id, alias, prefix, expStr )
%ADDEQUATION Add equation to graph
%   Detailed explanation goes here

respAdded = false;

if isempty(id)
    id = this.idProvider.giveID();
end

l1 = length(this.equations);
l2 = length(this.equationAliasArray);
l3 = length(this.equationIdArray);

if (l1==l2) && (l2==l3)
    tempEquation = Equation(id, alias, prefix, expStr);
    this.equations(end+1) = tempEquation;
    this.equationAliasArray{end+1} = [prefix alias];
    this.equationIdArray(end+1) = id;
    this.equationIdToIndexArray(id) = l1+1;
    respAdded = true;
else
    error('Inconsistent equation arrays sizes');
end

end

