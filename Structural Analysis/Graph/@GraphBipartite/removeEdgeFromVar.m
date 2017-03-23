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
    this.variables(varIndices(i)).edgeIdArray = setdiff(this.variables(varIndices(i)).edgeIdArray,edgeId);
    this.variables(varIndices(i)).neighbourIdArray = setdiff(this.variables(varIndices(i)).neighbourIdArray,equId);
end

resp = true;

end

