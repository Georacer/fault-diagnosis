function [ intervals ] = getLimits( this, indices )
%GETLIMITS Get the domains of the input variables
%   Detailed explanation goes here

intervals = zeros(length(indices),2);

for i=1:length(indices)
    index = indices(i);
    intervals(i,1) = this.variables(index).limit_lower;
    intervals(i,2) = this.variables(index).limit_upper;
end


end

