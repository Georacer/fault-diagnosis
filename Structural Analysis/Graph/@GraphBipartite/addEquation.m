function [respAdded, id] = addEquation( this, id, alias, expressionStr, description )
%ADDEQUATION Add equation to graph
%   Detailed explanation goes here

tempEquation = Equation(id, alias, expressionStr, description);
this.equations(end+1) = tempEquation;

respAdded = true;

end

