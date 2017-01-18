function resp = removeEdgeFromVar(this,varIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

if length(varIndices) ~= length(edgeIndices)
    error('variable/edge indices should come in pairs');
end

for i=1:length(varIndices)
    equId = this.edges(edgeIndices(i)).equId;
    edgeId = this.edge(edgeIndices(i)).id;
    this.equations(equIndices(i)).edgeIdArray = setdiff(this.equations(equIndices(i)).edgeIdArray,edgeId);
    this.equations(equIndices(i)).neigbourIdArray = setdiff(this.equations(equIndices(i)).neigbourIdArray,equId);
end

resp = true;

end

