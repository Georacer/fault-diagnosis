function resp = testPropertyEmpty( gh, id, property )
%TESTPROPTERTYEMPTY Summary of this function goes here
%   Detailed explanation goes here

resp = false;

gh.testPropertyExists(id,property);

index = gh.getIndexById(id);

if gh.isEquation(id)
    if isempty(gh.equations(index).(property))
        resp = true;
    end
elseif gh.isVariable(id)
    if isempty(gh.variables(index).(property))
        resp = true;
    end
elseif gh.isEdge(id)
    if isempty(gh.edges(index).(property))
        resp = true;
    end
else
    error('Unkown object type with id %d',id);
end
    
end

