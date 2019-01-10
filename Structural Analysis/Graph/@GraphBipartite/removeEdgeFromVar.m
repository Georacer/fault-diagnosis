function resp = removeEdgeFromVar(this,varIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

% debug = true;
debug = false;

if length(varIndices) ~= length(edgeIndices)
    error('variable/edge indices should come in pairs');
end

for i=1:length(varIndices)
    equId = this.edges(edgeIndices(i)).equId;
    edgeId = this.edges(edgeIndices(i)).id;
    if debug; fprintf('removeEdgeFromVar: Removing edge %d and equation %d from variable %d\n',edgeId, equId, this.variables(varIndices(i)).id); end
    
    new_edgeIdArray = this.variables(varIndices(i)).edgeIdArray;
    idx_to_del = new_edgeIdArray==edgeId;
    new_edgeIdArray(idx_to_del)=[];
    this.variables(varIndices(i)).edgeIdArray = new_edgeIdArray;
    
    new_neighbourIdArray = this.variables(varIndices(i)).neighbourIdArray;
    idx_to_del = new_neighbourIdArray==equId;
    new_neighbourIdArray(idx_to_del)=[];
    this.variables(varIndices(i)).neighbourIdArray = new_neighbourIdArray;
end

resp = true;

end

