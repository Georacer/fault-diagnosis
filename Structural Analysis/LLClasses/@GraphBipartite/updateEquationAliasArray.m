function updateEquationAliasArray(obj)
% Update the array holding the equation objects aliases
obj.equationAliasArray = cell(size(obj.equationArray));
for i=1:length(obj.equationAliasArray)
    obj.equationAliasArray{i} = [obj.equationArray(i).prefix obj.equationArray(i).alias];
end
end