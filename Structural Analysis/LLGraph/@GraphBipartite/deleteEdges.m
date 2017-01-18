function [ resp ] = deleteEdges( this, indices )
%DELETEEDGE Delete edges
%   Detailed explanation goes here

resp = false;

ind2Keep = setdiff(1:this.numEdges,indices);

this.edges = this.edges(ind2Keep);

resp = true;

end

