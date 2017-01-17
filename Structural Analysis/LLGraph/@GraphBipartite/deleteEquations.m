function [ resp ] = deleteEquations( this, ids )
%DELETEEQUATION Delete equations from graph
%   Detailed explanation goes here

% debug=true;
debug=false;

resp = false;

ind2keep = setdiff(1:this.numEqs,indices);

this.equations = this.equations(ind2Keep);

resp = true;

end

