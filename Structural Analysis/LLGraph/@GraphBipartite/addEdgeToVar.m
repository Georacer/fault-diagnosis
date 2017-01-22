function resp = addEdgeToVar(this,varIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

if length(varIndices) ~= length(edgeIndices)
    error('equation/edge indices should come in pairs');
end

for i=1:length(varIndices)
    varId = this.edges(edgeIndices(i)).varId;
    edgeId = this.edges(edgeIndices(i)).id;
    this.variables(varIndices(i)).edgeIdArray = [this.variables(varIndices(i)).edgeIdArray edgeId];
    this.variables(varIndices(i)).neighbourIdArray = [this.variables(varIndices(i)).neighbourIdArray varId];
end

resp = true;

end

