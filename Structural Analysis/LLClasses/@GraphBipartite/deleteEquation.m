function [ resp ] = deleteEquation( this, ids )
%DELETEEQUATION Delete equations from graph
%   Detailed explanation goes here

% debug=true;
debug=false;

resp = false;

if isempty(ids)
    resp = false;
    return;
end

% Find related edges
edgeIds = [];
for id = ids
    edgeIds = [edgeIds this.getEdgeIdByVertices(id,[])];        
end
edgeIndices = this.getIndexById(edgeIds);

% Find related variables
relVarIds = [];
for index = edgeIndices
    relVarIds = [relVarIds this.edges(index).varId];
end        
relVarIds = unique(relVarIds);

% Find exclusive variables and delete them
for id = relVarIds
    edgeIds2 = this.getEdgeIdByVertices([],id);
    if all(ismember(edgeIds2,edgeIds))
        if (debug)
            fprintf('*** Deleting variable with id %d\n',id);
        end
        this.deleteVariable(id);
    end
end

% Delete related edges first
edgeId = [];
for id = ids
    edgeId = [edgeId this.getEdgeIdByVertices(id,[])];
end
this.deleteEdge(edgeId);

% Delete equations
indices = this.getIndexById(ids);
ind2Keep = setdiff(1:this.numEqs,indices);

this.equations = this.equations(ind2Keep);
this.equationAliasArray = this.equationAliasArray(ind2Keep);
this.equationIdArray = this.equationIdArray(ind2Keep);

this.updateEquationIdToIndexArray();

resp = true;

%% NOTE: Can be sped up via the adjacency matrix

end

