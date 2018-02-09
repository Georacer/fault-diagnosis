function setMatchedVar( gh, index, value, equId )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

if length(value)==1
    value = value*ones(size(index));
end

for i=1:length(index)
    
    gh.variables(index(i)).isMatched = value(i);
    if value(i)
        gh.variables(index(i)).matchedTo = equId(i);
    else
        gh.variables(index(i)).matchedTo = [];
    end
    
end

end

