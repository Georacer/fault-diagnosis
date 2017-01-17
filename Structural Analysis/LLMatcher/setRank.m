function setRank( gh, id, rank )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

for i=1:length(id)
    
    index = gh.getIndexById(id(i));
    
    if gh.isVariable(id(i))
        gh.variables(index).rank = rank;
    elseif gh.isEquation(id(i))
        gh.equations(index).rank = rank;
    else
        error('Object with ID %d is neither a variable nor an equation',id(i));
    end
    
end

end

