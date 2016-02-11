function [ resp, id ] = addResidual( gh, equId )
%ADDRESIDUAL Summary of this function goes here
%   Detailed explanation goes here

alias = sprintf('res_%d',equId);
varProps.isKnown = true;
varProps.isMeasured = false;
varProps.isInput = false;
varProps.isOutput = false;
varProps.isResidual = true;
varProps.isMatched = true;
[resp, id] = gh.addVariable([],alias,varProps);
equIndex = gh.getIndexById(equId);
gh.setRank(id,gh.equations(equIndex).rank);

edgeProps.isMatched = true;
edgeProps.isDerivative = false;
edgeProps.isIntegral = false;
edgeProps.isNonSolvable = false;
gh.addEdge([],equId,id,edgeProps);

end

