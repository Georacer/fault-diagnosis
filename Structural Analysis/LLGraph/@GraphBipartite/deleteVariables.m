function [ resp ] = deleteVariables( this, indices )
%DELETEVARIABLE Delete variable from graph
%   Also delete related edges

% debug=true;
debug=false;

resp = false;

ind2keep = setdiff(1:this.numVars,indices);

this.variables = this.variables(ind2Keep);

resp = true;

end

