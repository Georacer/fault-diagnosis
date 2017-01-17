function [ id ] = getVarIdByProperty( gh,property,value,operator )
%GETVARIDBYPROPERTY Summary of gh function goes here
%   Detailed explanation goes here

if nargin<3
    value = true;
end

if nargin<4
    operator = '==';
end

id = [];

for i = 1:gh.numVars
    if gh.testPropertyExists(gh.variableIdArray(i),property)
        switch operator
            case '=='
                if (gh.variables(i).(property) == value)
                    id(end+1) = gh.variables(i).id;
                end
            case '<'
                if (gh.variables(i).(property) < value)
                    id(end+1) = gh.variables(i).id;
                end
            case '>'
                if (gh.variables(i).(property) > value)
                    id(end+1) = gh.variables(i).id;
                end
            case '<='
                if (gh.variables(i).(property) <= value)
                    id(end+1) = gh.variables(i).id;
                end
            case '>='
                if (gh.variables(i).(property) >= value)
                    id(end+1) = gh.variables(i).id;
                end
            case '~='
                if (gh.variables(i).(property) ~= value)
                    id(end+1) = gh.variables(i).id;
                end
            otherwise
                error('Unsupported operator %s\n',operator);
        end
    else
        error('Unsupported property %s',property)      
        
    end
end

end

