function updateEquationIdArray(obj)
% Update the array holding the equation objects IDs
obj.equationIdArray = zeros(size(obj.equationArray));
for i=1:length(obj.equationIdArray)
    obj.equationIdArray(i) = obj.equationArray(i).id;
end
end