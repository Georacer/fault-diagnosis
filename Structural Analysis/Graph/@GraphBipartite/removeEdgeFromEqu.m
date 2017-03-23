function resp = removeEdgeFromEqu(this,equIndices,edgeIndices)
%REMOVEEDGEFROMEQU Summary of this function goes here
%   Detailed explanation goes here

resp = false;

% debug=true;
debug=false;

if length(equIndices) ~= length(edgeIndices)
    error('equation/edge indices should come in pairs');
end

for i=1:length(equIndices)
    varId = this.edges(edgeIndices(i)).varId;
    edgeId = this.edges(edgeIndices(i)).id;
    if debug; fprintf('removeEdgeFromEqu: Removing edge %d and variable %d from equation %d\n',edgeId, varId, this.equations(equIndices(i)).id); end
    this.equations(equIndices(i)).edgeIdArray = setdiff(this.equations(equIndices(i)).edgeIdArray,edgeId);
    this.equations(equIndices(i)).neighbourIdArray = setdiff(this.equations(equIndices(i)).neighbourIdArray,varId);
end

resp = true;

end

