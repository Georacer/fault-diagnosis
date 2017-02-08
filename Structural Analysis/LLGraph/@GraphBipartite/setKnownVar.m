function setKnownVar( gh, index, value )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

if nargin<3
    value = true;
end

if length(value)==1;
    value = value*ones(size(index));
end

for i=1:length(index)
    gh.variables(index(i)).isKnown=value(i);
end

end

