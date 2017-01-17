function [ resp ] = updateVariableIdToIndexArray( gh )
%UPDATEVARIABLEIDTOINDEXARRAY Summary of this function goes here
%   Detailed explanation goes here

arrayNew = zeros(1,max(gh.variableIdArray));

arrayNew(gh.variableIdArray) = 1:length(gh.variableIdArray);

gh.variableIdToIndexArray = arrayNew;

resp = true;

end

