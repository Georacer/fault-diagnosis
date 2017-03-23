function resp = addEdgeToVar(this,varIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

if length(varIndices) ~= length(edgeIndices)
    error('equation/edge indices should come in pairs');
end

for i=1:length(varIndices)
    equId = this.edges(edgeIndices(i)).equId;
    edgeId = this.edges(edgeIndices(i)).id;
    if ismember(edgeId,this.variables(varIndices(i)).edgeIdArray)
        warning('addEdgeToVar: Attempting to add an already existing edge to a variable');
    end
    this.variables(varIndices(i)).edgeIdArray = [this.variables(varIndices(i)).edgeIdArray edgeId];
    this.variables(varIndices(i)).neighbourIdArray = [this.variables(varIndices(i)).neighbourIdArray equId];
end

resp = true;

end

