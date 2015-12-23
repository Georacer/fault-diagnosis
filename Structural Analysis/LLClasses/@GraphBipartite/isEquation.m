function [ resp ] = isEquation( this, id )
%ISEQUATION Answer whether an object is an equation
%   Detailed explanation goes here

index = find(this.equationIdArray==id);
if ~isempty(index)
    resp = true;
else
    resp = false;
end

end

