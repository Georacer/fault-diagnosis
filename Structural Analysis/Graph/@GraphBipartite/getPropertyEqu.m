function [ property ] = getPropertyEqu( gh, index, property )
%GETPROPERTYEQU Summary of this function goes here
%   Detailed explanation goes here

if gh.testPropertyExistsEqu(index,property)
    property = gh.equations(index).(property);
else
    property = [];
end

end

