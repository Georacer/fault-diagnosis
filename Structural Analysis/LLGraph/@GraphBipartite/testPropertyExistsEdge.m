function [ resp ] = testPropertyExistsEdge( gh, index, property )
%TESTPROPERTYEXISTS Summary of this function goes here
%   Detailed explanation goes here

resp = false;


if any(ismember(gh.edges(index).getProperties(),property))
    resp = true;
end


end

