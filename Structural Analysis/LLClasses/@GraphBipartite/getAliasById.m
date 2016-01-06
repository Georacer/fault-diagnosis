function [ alias ] = getAliasById( gh, id )
%GETALIASBYID Summary of gh function goes here
%   Detailed explanation goes here

if isempty(id)
    error('Empty ID given');
end
if id==0
    error('ID cannot be equal to 0');
end

index = gh.getIndexById(id);

if gh.isVariable(id)
    alias = gh.variables(index).alias;
elseif gh.isEquation(id)
    alias = gh.equations(index).prAlias;
elseif gh.isEdge(id)
    error('Edge objects do not have an alias');
else
    error('Unknown object type with id %d',id);
end

end

