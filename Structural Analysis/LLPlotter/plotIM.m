function [ fh ] = plotIM( graph, FSM )
%PLOTIM Plot isolability matrix
%   Detailed explanation goes here

faultIds = graph.getEquIdByProperty('isFaultable');
faultIndices = graph.getIndexById(faultIds);

IM = isolabilityMatrix(FSM);
fh = figure();
spy(IM);
set(gca,'XTick',1:length(faultIndices));
set(gca,'XTickLabel',graph.equationAliasArray(faultIndices));
set(gca,'YTick',1:length(faultIndices));
set(gca,'YTickLabel',graph.equationAliasArray(faultIndices));
title('Isolability Matrix');

end

