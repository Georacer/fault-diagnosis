function [ resp ] = testPropertyExists( gh, id, property )
%TESTPROPERTYEXISTS Summary of this function goes here
%   Detailed explanation goes here

resp = false;

index = gh.getIndexById(id);

if gh.isEquation(id)
    if any(ismember(gh.equations(index).propertyList,property))
        resp = true;
    end
elseif gh.isVariable(id)
    if any(ismember(gh.variables(index).propertyList,property))
        resp = true;
    end
elseif gh.isEdge(id)
    if any(ismember(gh.edges(index).propertyList,property))
        resp = true;
    end
else
    error('Unkown object type with id %d',id);
end

end

