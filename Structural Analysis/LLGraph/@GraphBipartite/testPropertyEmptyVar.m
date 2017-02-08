function resp = testPropertyEmptyVar( gh, index, property )
%TESTPROPTERTYEMPTY Summary of this function goes here
%   Detailed explanation goes here

resp = false;

gh.testPropertyExistsVar(index,property);

if isempty(gh.variables(index).(property))
    resp = true;
end


end

