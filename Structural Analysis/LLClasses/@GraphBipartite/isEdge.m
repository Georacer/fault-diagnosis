function resp = isEdge( gh, id )
%ISEDGE Summary of gh function goes here
%   Detailed explanation goes here

index = find(gh.edgeIdArray==id,1);
if ~isempty(index)
    resp = true;
else
    resp = false;
end

end

