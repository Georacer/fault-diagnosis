function [ resp ] = isAvailable( eh, varId )
%ISAVAILABLE Tell if the variable is available
%   Given a variable ID, respond if this variable has been given as an
%   input or calculated as an intermediate value

index = find(eh.readingsIdArray==varId);
if isempty(index)
    index = find(eh.evalIds==varId);
    if isempty(index)
        error('Cannot find the requested variable in either inputs or intermediate variables');
    end
    if isnan(eh.evalValues(index))
        resp = false;
        return
    else
        resp = true;
        return
    end
end

if isnan(eh.readingsValues(index))
    resp = false;
    return
else
    resp = true;
    return
end

end

