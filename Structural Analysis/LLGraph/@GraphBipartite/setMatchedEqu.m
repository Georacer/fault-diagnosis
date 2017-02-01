function setMatchedEqu( gh, index, value, varId )
%SETKNOWN Set a variable property known to true
%   Detailed explanation goes here

if length(value)==1;
    value = value*ones(size(index));
end

for i=1:length(index)
    
    gh.equations(index(i)).isMatched = value(i);
    if value(i)
        gh.equations(index(i)).matchedTo = varId(i);
    else
        gh.equations(index(i)).matchedTo = [];
    end
    
end

end

