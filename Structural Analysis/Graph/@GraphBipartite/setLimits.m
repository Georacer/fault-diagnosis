function [  ] = setLimits( this, indices, limits )
%SETLIMITS Set the domains of the input variables
% Limits are a N x 2 array. Each row is a lower/upper bound for the
% variable value

for i = 1:length(indices)
    index = indices(i);
    limit_lower = limits(i,1);
    limit_upper = limits(i,2);
    this.variables(index).limit_upper = limit_upper;
    this.variables(index).limit_lower = limit_lower;
end


end

