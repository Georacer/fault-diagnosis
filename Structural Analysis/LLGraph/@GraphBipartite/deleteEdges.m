function [ resp ] = deleteEdges( this, indices )
%DELETEEDGE Delete edges
%   Detailed explanation goes here

resp = false;

debug = false;
% debug = true;

if debug; fprintf('deleteEdges: Deleting edges with indices: '); fprintf('%d ',indices); fprintf('\n'); end

ind2Keep = setdiff(1:this.numEdges,indices);

this.edges = this.edges(ind2Keep);

resp = true;

end

