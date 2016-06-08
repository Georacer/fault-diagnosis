function resp = isEdge( gh, id )
%ISEDGE Summary of gh function goes here
%   Detailed explanation goes here

if id<=(length(gh.edgeIdToIndexArray))
    index = gh.edgeIdToIndexArray(id);
    if index==0
        resp = false;
    else
        resp = true;
    end
else
    resp = false;
end
    
    
% index = find(gh.edgeIdArray==id,1);
% if ~isempty(index)
%     resp = true;
% else
%     resp = false;
% end

end

