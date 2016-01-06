function [ index ] = getIndexById( gh,id )
%GETEQINDEXBYID Return object indices for the provided IDs
%   Detailed explanation goes here

index = zeros(1,length(id));

for i=1:length(id)
    
    if gh.isEquation(id(i))
        index(i) = gh.equationIdToIndexArray(id(i));
    elseif gh.isVariable(id(i))
        index(i) = gh.variableIdToIndexArray(id(i));
    elseif gh.isEdge(id(i))
        index(i) = gh.edgeIdToIndexArray(id(i));
    else
        error('Unknown object type with id %d',id(i));
    end
   
end

end

