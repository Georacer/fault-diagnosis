function [ val ] = evaluateSingle( eh, gh, edgeId )
%EVALUATESINGLE Evaluate a single function for one of its variables
%   Detailed explanation goes here

eqId = gh.getEquations(edgeId);
varId = gh.getVariables(edgeId);
varIds = gh.getVariables(eqId);

varIndex = gh.getIndexById(varId);

for i=setdiff(varIds,varId)
    if (~gh.isKnown(i))
        error('All variables except for the requested should be known');
        val = nan;
        return
    end
end
disp('Yay, evaluation is possible');
end

end

