function [ids] = getEdgesVar(gh,indices)
% Returns a cell array of the edges connected to edges
%OPTIONAL: option - [V2E, E2V] return only V2E/E2V edges

% debug = true;
debug = false;

ids = cell(1,length(indices));

for i=1:length(indices)
    ids{i} = gh.variables(indices(i)).edgeIdArray;
end

end