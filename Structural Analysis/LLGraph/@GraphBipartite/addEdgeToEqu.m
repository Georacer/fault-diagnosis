function resp = addEdgeToEqu(this,equIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

if length(equIndices) ~= length(edgeIndices)
    error('equation/edge indices should come in pairs');
end

for i=1:length(equIndices)
    varId = this.edges(edgeIndices(i)).varId;
    edgeId = this.edge(edgeIndices(i)).id;
    this.equations(equIndices(i)).edgeIdArray = [this.equations(equIndices(i)).edgeIdArray edgeId];
    this.equations(equIndices(i)).neigbourIdArray = [this.equations(equIndices(i)).neigbourIdArray varId];
end

resp = true;

end

