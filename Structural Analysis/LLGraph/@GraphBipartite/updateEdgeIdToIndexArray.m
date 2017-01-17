function [ resp ] = updateEdgeIdToIndexArray( gh )
%UPDATEEDGEIDTOINDEXARRAY Summary of this function goes here
%   Detailed explanation goes here

arrayNew = zeros(1,max(gh.edgeIdArray));

arrayNew(gh.edgeIdArray) = 1:length(gh.edgeIdArray);

gh.edgeIdToIndexArray = arrayNew;

resp = true;

end

