function resp = addEdgeToVar(this,varIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

if length(varIndices) ~= length(edgeIndices)
    error('equation/edge indices should come in pairs');
end

for i=1:length(varIndices)
    varId = this.edges(edgeIndices(i)).varId;
    edgeId = this.edge(edgeIndices(i)).id;
    this.equations(varIndices(i)).edgeIdArray = [this.variables(varIndices(i)).edgeIdArray edgeId];
    this.equations(varIndices(i)).neigbourIdArray = [this.variables(varIndices(i)).neigbourIdArray varId];
end

resp = true;

end

