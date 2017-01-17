function resp = setProperty( gh, id, property, value )
%SETPROPERTYOR Summary of gh function goes here
%   Detailed explanation goes here

resp = false;

if nargin<4
    value = true;
end

if gh.testPropertyExists(id,property)
    
    if gh.isEquation(id)
        index = gh.getIndexById(id);
        gh.equations(index).(property) = value ;
    elseif gh.isVariable(id)
        index = gh.getIndexById(id);
        gh.variables(index).(property) = value ;
    elseif gh.isEdge(id)
        index = gh.getIndexById(id);
        gh.edges(index).(property) = value ;
    else
        error('Unkown object type with id %d',id);
    end
    
else
    error('Unknown property %s for object with ID %d',property,id);
end

end

