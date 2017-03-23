function [ resp ] = isKnownVar( gh, indices )
%ISMATCHED Check if this variable is known
%   Detailed explanation goes here

resp = zeros(1,length(indices));

for i=1:length(indices)
    resp(i)=gh.variables(indices(i)).isKnown;
end

end

