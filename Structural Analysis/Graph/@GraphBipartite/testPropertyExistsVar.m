function [ resp ] = testPropertyExistsVar( gh, index, property )
%TESTPROPERTYEXISTS Summary of this function goes here
%   Detailed explanation goes here

resp = false;


if any(ismember(gh.variables(index).getProperties(),property))
    resp = true;
end


end

