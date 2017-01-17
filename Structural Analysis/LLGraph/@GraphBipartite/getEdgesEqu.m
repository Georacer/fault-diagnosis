function [ids] = getEdgesEqu(gh,indices)
% Returns a cell array of the edges connected to edges

% debug = true;
debug = false;

ids = cell(1,length(indices));

for i=1:length(indices)
    ids{i} = gh.equations(indices(i)).edgeIdArray;
end

end