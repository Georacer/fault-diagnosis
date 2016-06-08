function [ resp ] = isVariable( gh, id )
%ISVARIABLE Answer whether an object is a variable
%   Detailed explanation goes here

if id<=(length(gh.variableIdToIndexArray))
    index = gh.variableIdToIndexArray(id);
    if index==0
        resp = false;
    else
        resp = true;
    end
else
    resp = false;
end

% index = find(this.variableIdArray==id,1);
% if ~isempty(index)
%     resp = true;
% else
%     resp = false;
% end

end

