function [ val ] = evaluateSingle( gh, eqId, varId )
%EVALUATESINGLE Evaluate a single function for one of its variables
%   Detailed explanation goes here

if (~gh.isEquation(eqId))
    error('Invalid equation ID');
    val = nan;
elseif (~gh.isVariable(varId))
    error('Invalid variable ID');
    val = nan;
    return
else
    varIds = gh.getVariables(eqId);
    if (~ismember(varId, varIds))
        error('Requested variable does not relate to constraint');
        val = nan;
        return
    else
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

end

