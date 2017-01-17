function [ equIds ] = getEquations( gh, id )
%GETVARIABLES get variables related to an equation or edge
%   Detailed explanation goes here

% debug = true;
debug = false;

equIds = [];

for i=1:length(id)
    
    if gh.isVariable(id(i))        
        edgeIds = gh.getEdgeIdByVertices([],id(i));
        if debug fprintf('getEquations: Related edges: %d\n',length(edgeIds)); end
        edgeIndices = gh.getIndexById(edgeIds);
        tempVect = zeros(size(edgeIndices));
        
        k = 1;
        for i=edgeIndices
            tempVect(k) = gh.edges(i).equId;
            if debug fprintf('getEquations: Ran loop %d\n',k); end
            k = k + 1;
        end
        equIds = [equIds tempVect];
        
    elseif gh.isEdge(id(i))
        edgeIndex = gh.getIndexById(id(i));
        equIds(end+1) = gh.edges(edgeIndex).equId;
        
    elseif gh.isEquation(id(i))
        warning('Requested getEquations from an equation');
        equIds(end+1) = id(i);
        
    else
        error('Unknown object of id %d\n',id(i));
    end
    
end

end

