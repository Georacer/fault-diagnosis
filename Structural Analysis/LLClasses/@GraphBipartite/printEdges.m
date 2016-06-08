function [ s ] = printEdges( gh, ids )
%PRINTEDGES Summary of this function goes here
%   Detailed explanation goes here

edgeIndices = gh.getIndexById(ids);

s = [];
for i=edgeIndices
    equInd = gh.getIndexById(gh.edges(i).equId);
    varInd = gh.getIndexById(gh.edges(i).varId);
    s = [s sprintf('%s -> %s\n',gh.equationAliasArray{equInd},gh.variableAliasArray{varInd})];
end

disp(s)

end

