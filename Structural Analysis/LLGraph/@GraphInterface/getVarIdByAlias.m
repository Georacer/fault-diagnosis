function [ id ] = getVarIdByAlias( this, alias )
%GETVARIDBYALIAS Summary of this function goes here
%   Detailed explanation goes here

varIndex = find(strcmp(this.variableAliasArray,alias));
id = this.variableIdArray(varIndex);

end

