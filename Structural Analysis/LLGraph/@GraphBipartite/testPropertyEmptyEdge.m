function resp = testPropertyEmptyEdge( gh, index, property )
%TESTPROPTERTYEMPTY Summary of this function goes here
%   Detailed explanation goes here

resp = false;

gh.testPropertyExistsEdge(id,property);

if isempty(gh.edges(index).(property))
    resp = true;
end


end

