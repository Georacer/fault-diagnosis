function [ id ] = getEquIdByAlias( this, alias )
%GETEQUIDBYALIAS Summary of this function goes here
%   Detailed explanation goes here

equIndex = find(strcmp(this.equationAliasArray,alias));
id = this.equationIdArray(equIndex);

end

