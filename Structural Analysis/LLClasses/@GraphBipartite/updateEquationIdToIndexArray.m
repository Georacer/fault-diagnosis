function [ resp ] = updateEquationIdToIndexArray( gh )
%UPDATEEQUATIONIDTOINDEXARRAY Summary of this function goes here
%   Detailed explanation goes here

arrayNew = zeros(1,max(gh.equationIdArray));

arrayNew(gh.equationIdArray) = 1:length(gh.equationIdArray);

gh.equationIdToIndexArray = arrayNew;

resp = true;

end

