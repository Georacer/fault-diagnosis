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
    
    new_edgeIdArray = this.equations(equIndices(i)).edgeIdArray;
    idx_to_del = new_edgeIdArray==edgeId;
    new_edgeIdArray(idx_to_del)=[];
    this.equations(equIndices(i)).edgeIdArray = new_edgeIdArray;
    
    new_neighbourIdArray = this.equations(equIndices(i)).neighbourIdArray;
    idx_to_del = new_neighbourIdArray==varId;
    new_neighbourIdArray(idx_to_del)=[];
    this.equations(equIndices(i)).neighbourIdArray = new_neighbourIdArray;
end

resp = true;

end

