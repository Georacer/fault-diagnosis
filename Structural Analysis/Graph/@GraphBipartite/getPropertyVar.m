function [ property ] = getPropertyVar( gh, index, property )
%GETPROPERTYEQU Summary of this function goes here
%   Detailed explanation goes here

if gh.testPropertyExistsVar(index,property)
    property = gh.variables(index).(property);
else
    property = [];
end

end

