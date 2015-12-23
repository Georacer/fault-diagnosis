function [ alias ] = getAliasById( this, id )
%GETALIASBYID Summary of this function goes here
%   Detailed explanation goes here

if this.isVariable(id)
    index = this.getVarIndexById(id);
    alias = this.variableArray(index).alias;
elseif this.isEquation(id)
    index = this.getEqIndexById(id);
    alias = this.equationArray(index).alias;
else
    error('Unknown id %d\n',id);
end

end

