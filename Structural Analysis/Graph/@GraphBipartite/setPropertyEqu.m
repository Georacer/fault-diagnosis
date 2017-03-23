function resp = setPropertyEqu( gh, index, property, value )
%SETPROPERTYOR Summary of gh function goes here
%   Detailed explanation goes here

resp = false;

if nargin<4
    value = true;
end

gh.equations(index).(property) = value ;

resp = true;

end

