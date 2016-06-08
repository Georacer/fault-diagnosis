function [ varIds ] = getVariables( gh, id )
%GETVARIABLES get variables related to an equation or edge
%   Detailed explanation goes here

% debug = true;
debug = false;

varIds = [];

for i=1:length(id)
    
    if gh.isEquation(id(i))        
        edgeIds = gh.getEdgeIdByVertices(id(i),[]);
        if debug fprintf('getVariables: Related edges: %d\n',length(edgeIds)); end
        edgeIndices = gh.getIndexById(edgeIds);
        tempVect = zeros(size(edgeIndices));
        
        k = 1;
        for i=edgeIndices
            tempVect(k) = gh.edges(i).varId;
            if debug fprintf('getVariables: Ran loop %d\n',k); end
            k = k + 1;
        end
        varIds = [varIds tempVect];
        
    elseif gh.isEdge(id(i))
        edgeIndex = gh.getIndexById(id(i));
        varIds(end+1) = gh.edges(edgeIndex).varId;
        
    elseif gh.isVariable(id(i))
        warning('Requested getVariables from a variable');
        varIds(end+1) = id(i);
        
    else
        error('Unknown object of id %d\n',id(i));
    end
    
end

end

