function [ resp ] = isMatched( gh, id )
%ISMATCHED Summary of this function goes here
%   Detailed explanation goes here

index = gh.getIndexById(id);

if gh.isVariable(id)
    resp = gh.variables(index).isMatched;
elseif gh.isEquation(id)
    resp = gh.equations(index).isMatched;
elseif gh.isEdge(id)
    resp = gh.edges(index).isMatched;
else
    error('Unkown object type with ID %d',id);
end

end

