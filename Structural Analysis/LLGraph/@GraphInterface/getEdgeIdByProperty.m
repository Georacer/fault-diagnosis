function [ id ] = getEdgeIdByProperty( gh,property,value,operator )
%GETEDGEIDBYPROPERTY Summary of gh function goes here
%   Detailed explanation goes here

if nargin<3
    value = true;
end

if nargin<4
    operator = '==';
end

id = [];

for i = 1:gh.numEdges
    if gh.testPropertyExists(gh.edgeIdArray(i),property)
        switch operator
            case '=='
                if (gh.edges(i).(property) == value)
                    id(end+1) = gh.edges(i).id;
                end
            case '<'
                if (gh.edges(i).(property) < value)
                    id(end+1) = gh.edges(i).id;
                end
            case '>'
                if (gh.edges(i).(property) > value)
                    id(end+1) = gh.edges(i).id;
                end
            case '<='
                if (gh.edges(i).(property) <= value)
                    id(end+1) = gh.edges(i).id;
                end
            case '>='
                if (gh.edges(i).(property) >= value)
                    id(end+1) = gh.edges(i).id;
                end
            case '~='
                if (gh.edges(i).(property) ~= value)
                    id(end+1) = gh.edges(i).id;
                end
            otherwise
                error('Unsupported operator %s\n',operator);
        end
    else
        error('Unsupported property %s',property)      
        
    end
end

end

