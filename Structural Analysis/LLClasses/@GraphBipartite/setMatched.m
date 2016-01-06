function setMatched( gh, id, value )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

if nargin<3
    value = true;
end

for i=1:length(id)
    
    index = gh.getIndexById(id(i));
    
    if gh.isVariable(id(i))
        gh.variables(index).isMatched = value;
    elseif gh.isEquation(id(i))
        gh.equations(index).isMatched = value;
    elseif gh.isEdge(id(i))
        gh.edges(index).isMatched = value;
    else
        error('Unknown object type with id %d',id);
    end
    
end

end

