function [ graph ] = getOver( this )
%GETOVER Over-constrained partition
%   Return a new graph object, which contains only the over-constrained
%   partiotion of the input graph object

dm = GetDMParts(this.liusm.X);
edgeInd2Keep = dm.Mp.row;
edgeInd2Del = setdiff(1:this.numEqs, edgeInd2Keep);
edgeIds2Del = this.equationIdArray(edgeInd2Del);

graph = this.copy();
graph.deleteEquation(edgeIds2Del);    

end

