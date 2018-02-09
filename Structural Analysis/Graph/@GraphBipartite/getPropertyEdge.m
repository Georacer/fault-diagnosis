function [ property ] = getPropertyEdge( gh, index, property )
%GETPROPERTYEQU Summary of this function goes here
%   Detailed explanation goes here

if gh.testPropertyExistsEdge(index,property)
    property = gh.edges(index).(property);
else
    property = [];
end

end

