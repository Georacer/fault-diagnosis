function [ respAdded, id ] = addEdge( gh, id,equId,varId,edgeProps )
%ADDEDGE Summary of gh function goes here
%   Detailed explanation goes here

% debug = true;
debug = false;

respAdded = false;

l1 = length(gh.edges);
l2 = length(gh.edgeIdArray);

if (l1==l2)

    % Lookup the edge
    edgeId = gh.getEdgeIdByVertices(equId, varId);

    if isempty(edgeId) % gh edge was not yet met

        if isempty(id)
            id = gh.idProvider.giveID();
        end

        tempEdge = Edge(id,equId,varId); % Create a new edge object
        tempEdge.isMatched = edgeProps.isMatched;
        tempEdge.isDerivative = edgeProps.isDerivative;
        tempEdge.isIntegral = edgeProps.isIntegral;
        tempEdge.isNonSolvable = edgeProps.isNonSolvable;
        
        gh.edges(end+1) = tempEdge;
        gh.edgeIdArray(end+1) = id;
        gh.edgeIdToIndexArray(id) = l1+1;
        
        equIndex = gh.getIndexById(equId);
        varIndex = gh.getIndexById(varId);
        gh.equations(equIndex).edgeIdArray(end+1) = id;
        gh.variables(varIndex).edgeIdArray(end+1) = id;
        
        respAdded = true;
        if debug fprintf('addEdge: Created new edge from (%d,%d) with ID %d\n',equId,varId,id); end
    else
        gh.setPropertyOR(edgeId,'isMatched',edgeProps.isMatched);
        gh.setPropertyOR(edgeId,'isDerivative',edgeProps.isDerivative);
        gh.setPropertyOR(edgeId,'isIntegral',edgeProps.isIntegral);
        gh.setPropertyOR(edgeId,'isNonSolvable',edgeProps.isNonSolvable);
    end
else
    error('Inconsistent edge arrays sizes');
end


end

