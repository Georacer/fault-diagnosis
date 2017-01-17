function [ id ] = getEdgeIdByVertices( gh, equId, varId )
%GETEDGEIDBYVERTICES Find edge ids by vertices
%   Detailed explanation goes here

id = [];

for i=1:gh.numEdges
    if isempty(equId)
        if (gh.edges(i).varId == varId)
            id = [id gh.edges(i).id];
        end
    elseif isempty(varId)
        if (gh.edges(i).equId == equId)
            id = [id gh.edges(i).id];
        end
        
    else
        if (gh.edges(i).equId==equId) && (gh.edges(i).varId==varId)
            id = gh.edges(i).id;
            return
        end
    end
end

end

