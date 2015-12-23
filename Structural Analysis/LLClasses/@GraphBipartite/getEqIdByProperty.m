function [ id ] = getEqIdByProperty(obj,property,value)
%GETIDBYPROPERTY Return an ID array with objects with requested property
%   This applies and searches both equations and variables

if nargin<3
    value = true;
end

id = [];

for i = 1:obj.numEqs
    if isprop(obj.equationArray(i),property) && (obj.equationArray(i).(property) == value)
        id(end+1) = obj.equationArray(i).id;
    end  
end

end