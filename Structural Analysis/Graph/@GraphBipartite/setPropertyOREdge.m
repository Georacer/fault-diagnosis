function resp = setPropertyOREdge( gh, index, property, value )
%SETPROPERTYOR Summary of gh function goes here
%   Detailed explanation goes here

resp = false;

if nargin<4
    value = true;
end

% Logical OR for properties
if gh.testPropertyEmptyEdge(index, property)
    gh.edges(index).(property) = value;
else
    gh.edges(index).(property) = gh.edges(index).(property) || value ;
end

end

