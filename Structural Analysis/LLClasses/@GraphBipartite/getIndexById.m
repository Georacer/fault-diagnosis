function [ index, type ] = getIndexById( gh,id )
%GETEQINDEXBYID Return object indices for the provided IDs
%   Also returns the object type:
%   0: equation
%   1: variable
%   2: edge

index = zeros(1,length(id));
type = zeros(1,length(id));

for i=1:length(id)
    
    if gh.isEquation(id(i))
        index(i) = gh.equationIdToIndexArray(id(i));
        type(i) = 0;
    elseif gh.isVariable(id(i))
        index(i) = gh.variableIdToIndexArray(id(i));
        type(i) = 1;
    elseif gh.isEdge(id(i))
        index(i) = gh.edgeIdToIndexArray(id(i));
        type(i) = 2;
    else
        error('Unknown object type with id %d',id(i));
    end
   
end

end

