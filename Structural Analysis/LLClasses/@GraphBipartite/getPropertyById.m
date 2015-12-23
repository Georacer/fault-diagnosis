function [ value ] = getPropertyById( this, id, property )
%GETPROPERTYBYID Get object property value by id
%   Detailed explanation goes here

% Search in the equation array
index = this.getEqIndexById(id);
if ~isempty(index) && isprop(this.equationArray(index),property)
    value = this.equationArray(index).(property);
else % Search in the variable array
    index = this.getVarIndexById(id);
    if ~isempty(index) && isprop(this.variableArray(index),property)
        value = this.variableArray(index).(property);
    end
end

end

