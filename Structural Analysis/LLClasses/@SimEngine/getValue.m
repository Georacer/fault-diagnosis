function [ value ] = getValue( eh, varId )
%GETVALUE Return the stored value for requested variable
%   Detailed explanation goes here

index_readings = find(eh.readingsIdArray==varId);
index_eval = find(eh.evalIds==varId);

if ~isempty(index_readings)
    value = eh.readingsValues(index_readings);
    return
end
if ~isempty(index_eval)
    value = eh.evalValues(index_eval);
    return
end
error('Cannot find the requested variable in either inputs or intermediate variables');

end

