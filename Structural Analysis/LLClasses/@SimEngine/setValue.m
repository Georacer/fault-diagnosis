function setValue( eh, varId, value )
%SETVALUE Set the value of an intermediate variable
%   Detailed explanation goes here

index_readings = find(eh.readingsIdArray==varId);
index_eval = find(eh.evalIds==varId);
index_residual = find(eh.residualIds==varId);

if ~isempty(index_readings)
    error('Cannot write on a reading');
end
if ~isempty(index_eval)
    eh.evalValues(index_eval) = value;
    return
end
if ~isempty(index_residual)
    eh.residualValues(index_residual) = value;
    return
end

error('Cannot find the requested variable in any ID array');

end

