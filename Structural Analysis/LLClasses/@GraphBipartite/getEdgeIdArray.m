function [ ids ] = getEdgeIdArray( gh, id )
%GETEDGEIDARRAY Return edgeIdArray
%   Detailed explanation goes here

if length(id)>1
    error('This function does not support array inputs');
end

[index, type] = gh.getIndexById(id);
if type==0
    ids = gh.equations(index).edgeIdArray;
elseif type ==1
    ids = gh.variables(index).edgeIdArray;
else
    error('This function supports only Node arguments');
end

end

