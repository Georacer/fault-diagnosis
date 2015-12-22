function updateVariableAliasArray(obj)
% Update the array holding the variable objects
obj.variableAliasArray = cell(size(obj.variableArray));
for i=1:length(obj.variableAliasArray)
    obj.variableAliasArray{i} = obj.variableArray(i).alias;
end
end