function [ resp ] = isEquation( this, id )
%ISEQUATION Answer whether an object is an equation
%   Detailed explanation goes here

if isempty(id)
    error('Empty id argument');
end

if length(id)>1
    error('Cannot support array inputs');
end

index = find(this.equationIdArray==id,1);
if ~isempty(index)
    resp = true;
else
    resp = false;
end

end

