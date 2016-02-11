function resp = setPropertyOR( gh, id, property, value )
%SETPROPERTYOR Summary of gh function goes here
%   Detailed explanation goes here

resp = false;

if nargin<4
    value = true;
end

% Logical OR for properties
    if gh.testPropertyEmpty(id, property)
        if isEquation(id)
            index = gh.getIndexById(id);
            gh.equations(index).(property) = value;
        elseif isVariable(id)
            index = gh.getIndexById(id);
            gh.variables(index).(property) = value;
        elseif isEdge(id)
            index = gh.getIndexById(id);
            gh.edges(index).(property) = value;
        else
            error('Unknown object type with id %d',id);
        end
    else
        if gh.isEquation(id)
            index = gh.getIndexById(id);
            gh.equations(index).(property) = gh.equations(index).(property) || value ;
        elseif gh.isVariable(id)
            index = gh.getIndexById(id);
            gh.variables(index).(property) = gh.variables(index).(property) || value ;
        elseif gh.isEdge(id)
            index = gh.getIndexById(id);
            gh.edges(index).(property) = gh.edges(index).(property) || value ;
        else
            error('Unkown object type with id %d',id);
        end
    end

end

