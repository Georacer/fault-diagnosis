function [ index ] = getEqIndexById( obj,id )
%GETEQINDEXBYID Summary of this function goes here
%   Detailed explanation goes here

index = zeros(length(id),1);

for i=1:length(id)
    
    for j=1:obj.numEqs
        if obj.equationArray(j).id == id(i)
            index(i) = j;
        end
    end
    
end

end

