function [ value ] = getPropertyById( gh, id, property )
%GETPROPERTYBYID Get object property value by id
%   Detailed explanation goes here

index = gh.getIndexById(id);
if index==0
    error('Unkown id %d',id);
elseif gh.testPropertyExists(id,property)
    if gh.isEquation(id)
        value = gh.equations(index).(property);
    elseif gh.isVariable(id)
            value = gh.variables(index).(property);
    elseif gh.isEdge(id)
        value = gh.edges(index).(property);
    else
        error('Unknown object type with id %d',id);
    end
        
end        
    
end

