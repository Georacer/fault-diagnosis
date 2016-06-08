function [ Eout, mapPost2Pre, mapPre2Post ] = makeProperList( Ein )
%MAKEPROPERLIST Proper-ifies vertex names in an edge list
%   Given an edge list E(m,2), re-names the vertex numbers, so that when
%   sorted, they form an 1:m array

preNames = unique(Ein)';
mapPost2Pre = preNames;

postNames = 1:length(preNames);

mapPre2Post = zeros(1,max(preNames));

k=1;
for i=preNames
    mapPre2Post(i) = k;
    k = k+1;    
end

Eout = arrayfun(@(x) mapPre2Post(x), Ein);

end

