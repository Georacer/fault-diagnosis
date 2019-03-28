function [ num_elements ] = parseCellRecursive( c )
%PARSECELLRECURSIVE Calculate the total number of numerical elements a recursive cell array has
%   Detailed explanation goes here

if ~iscell(c)
    if isempty(c)
        num_elements = 0;
    else
        num_elements = 1;
    end
    return
else
    num_elements = 0;
    for i=1:length(c)
        num_elements = num_elements + parseCellRecursive(c{i});
    end
    return;
end


end

