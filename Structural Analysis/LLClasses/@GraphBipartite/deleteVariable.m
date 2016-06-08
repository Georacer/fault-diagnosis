function [ resp ] = deleteVariable( this, ids )
%DELETEVARIABLE Delete variable from graph
%   Also delete related edges

% debug=true;
debug=false;

resp = false;

% Delete related edges first
for id = ids
    edgeId = this.getEdgeIdByVertices([],id);
    this.deleteEdge(edgeId);
end

% Delete variables

ind2Del = this.getIndexById(ids);
ind2Keep = setdiff(1:this.numVars, ind2Del);

this.variables = this.variables(ind2Keep);
if debug
    fprintf('*** %d variables left in graph\n',this.numVars);
end
this.variableAliasArray = this.variableAliasArray(ind2Keep);
% if debug
%     fprintf('variableIdArray pre deletion:\n');
%     this.variableIdArray
%     fprintf('variableIdArray post deletion:\n');
%     this.variableIdArray(ind2Keep)
% end
this.variableIdArray = this.variableIdArray(ind2Keep);

this.updateVariableIdToIndexArray();

resp = true;

end

