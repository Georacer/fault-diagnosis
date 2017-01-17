function [ resp ] = deleteEdge( this, ids )
%DELETEEDGE Delete edges
%   Detailed explanation goes here

resp = false;

ind2Del = this.getIndexById(ids);
ind2Keep = setdiff(1:this.numEdges, ind2Del);

this.edges = this.edges(ind2Keep);
this.edgeIdArray = this.edgeIdArray(ind2Keep);

this.updateEdgeIdToIndexArray();

resp = true;

end

