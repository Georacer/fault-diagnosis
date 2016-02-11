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

alias = cell(1,length(id));

k=1;
for ind=index
    
    if gh.isVariable(id(k))
        alias{k} = gh.variables(ind).alias;
    elseif gh.isEquation(id(k))
        alias{k} = gh.equations(ind).prAlias;
    elseif gh.isEdge(id(k))
        error('Edge objects do not have an alias');
    else
        error('Unknown object type with id %d',id(k));
    end
    
    k = k+1;
    
end

if length(alias) == 1
    alias = alias{1};
end

end

