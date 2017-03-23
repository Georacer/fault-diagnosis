function resp = testPropertyEmptyEqu( gh, index, property )
%TESTPROPTERTYEMPTY Summary of this function goes here
%   Detailed explanation goes here

resp = false;

gh.testPropertyExistsEqu(id,property);

if isempty(gh.equations(index).(property))
    resp = true;
end


end

