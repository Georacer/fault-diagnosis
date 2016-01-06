function [ id ] = getEquIdByProperty(gh,property,value,operator)
%GETIDBYPROPERTY Return an ID array with objects with requested property
%   gh applies and searches both equations and variables

if nargin<3
    value = true;
end

if nargin<4
    operator = '==';
end

id = [];

for i = 1:gh.numEqs
    if gh.testPropertyExists(gh.equationIdArray(i),property)
        switch operator
            case '=='
                if (gh.equations(i).(property) == value)
                    id(end+1) = gh.equations(i).id;
                end
            case '<'
                if (gh.equations(i).(property) < value)
                    id(end+1) = gh.equations(i).id;
                end
            case '>'
                if (gh.equations(i).(property) > value)
                    id(end+1) = gh.equations(i).id;
                end
            case '<='
                if (gh.equations(i).(property) <= value)
                    id(end+1) = gh.equations(i).id;
                end
            case '>='
                if (gh.equations(i).(property) >= value)
                    id(end+1) = gh.equations(i).id;
                end
            case '~='
                if (gh.equations(i).(property) ~= value)
                    id(end+1) = gh.equations(i).id;
                end
            otherwise
                error('Unsupported operator %s\n',operator);
        end
    else
        error('Unsupported property %s',property)        
    end
end

end