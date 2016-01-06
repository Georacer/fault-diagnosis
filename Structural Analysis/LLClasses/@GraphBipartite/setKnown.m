function setKnown( gh, id, value )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

if nargin<3
    value = true;
end

for i=1:length(id)
    
    if gh.isVariable(id(i))
        index = gh.getIndexById(id(i));
        gh.variables(index).isKnown = value;
    else
        error('Node with id %d is not a variable',id);
    end
end

end

