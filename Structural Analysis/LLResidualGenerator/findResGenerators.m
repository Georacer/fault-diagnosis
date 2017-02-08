function [ ids ] = findResGenerators( gi )
%FINDRESGENERATORS Find unmatched constraints which can generate residuals
%   Detailed explanation goes here

CU = gi.getEquIdByProperty('isMatched', false);
ids = [];

for equId = CU
    vars = gi.getVariablesUnknown(equId);
    if isempty(vars)
        ids = [ids equId];
    end
end

end

