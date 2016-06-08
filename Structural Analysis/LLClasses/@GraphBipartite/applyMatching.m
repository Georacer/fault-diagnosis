function [ resp ] = applyMatching( gh, M )
%APPLYMATCHING Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(M)
    m = M(i);
    equId = gh.getEquations(m);
    equInd = gh.getIndexById(equId);
    varId = gh.getVariables(m);
    varInd = gh.getIndexById(varId);
    
    gh.setMatched(m);
    gh.setMatched(varId);
    gh.variables(varInd).matchedTo = equId;
    gh.setMatched(equId);
    gh.equations(equInd).matchedTo = varId;
    gh.setKnown(varId);
end

resp = true;

end

