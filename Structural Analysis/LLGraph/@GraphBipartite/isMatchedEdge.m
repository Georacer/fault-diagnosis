function [ resp ] = isMatchedEdge( gh, indices )
%ISMATCHED Check if variables are matched
%   Detailed explanation goes here

resp = zeros(1,length(indices));

for i=1:length(indices)
    resp(i)=gh.edges(indces(i)).isMatched;
end

end

