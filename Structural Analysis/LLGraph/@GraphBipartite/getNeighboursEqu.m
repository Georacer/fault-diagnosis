function [ vertexIds ] = getNeighboursEqu( gh, indices )
%GETVARIABLES get variables related to an equation or edge
%   Returns a cell array

% debug = true;
debug = false;

vertexIds = cell(1,length(indices));

for i=1:length(indices)
    
    vertexIds{i} = gh.equations(indices(i)).neighbourIdArray;
    
end

end
