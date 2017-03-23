function [ resp ] = testPropertyExistsEqu( gh, index, property )
%TESTPROPERTYEXISTS Summary of this function goes here
%   Detailed explanation goes here

resp = false;


if any(ismember(gh.equations(index).getProperties(),property))
    resp = true;
end


end

