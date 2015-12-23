function [ index ] = getVarIndexById( obj,id )
%GETVARINDEXBYID Summary of this function goes here
%   Detailed explanation goes here

for i=1:obj.numVars
    if obj.variableArray(i).id == id
        index = i;
    end    
end

end



