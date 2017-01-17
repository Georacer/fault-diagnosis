function [ resp ] = isEquation( gh, id )
%ISEQUATION Answer whether an object is an equation
%   Detailed explanation goes here

if isempty(id)
    error('Empty id argument');
end

if length(id)>1
    error('Cannot support array inputs');
end

if id<=(length(gh.equationIdToIndexArray))
    index = gh.equationIdToIndexArray(id);
    if index==0
        resp = false;
    else
        resp = true;
    end
else
    resp = false;
end

% index = find(this.equationIdArray==id,1);
% if ~isempty(index)
%     resp = true;
% else
%     resp = false;
% end

end

