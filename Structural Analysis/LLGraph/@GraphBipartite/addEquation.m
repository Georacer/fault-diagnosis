function [respAdded, id] = addEquation( this, id, alias, description )
%ADDEQUATION Add equation to graph
%   Detailed explanation goes here

tempEquation = Equation(id, alias, description);
this.equations(end+1) = tempEquation;

end

