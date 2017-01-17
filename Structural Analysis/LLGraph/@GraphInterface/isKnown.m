function [ resp ] = isKnown( gh, id )
%ISMATCHED Summary of this function goes here
%   Detailed explanation goes here

index = gh.getIndexById(id);

if gh.isVariable(id)
    resp = gh.variables(index).isKnown;
elseif gh.isEquation(id)
    error('isKnown applies only to Variable objects');
elseif gh.isEdge(id)
    error('isKnown applies only to Variable objects');
else
    error('Unkown object type with ID %d',id);
end

end

