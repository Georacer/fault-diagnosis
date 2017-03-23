function [ fh ] = plotFSM( graph, FSM)
%PLOTFSM Plot the Fault Signature Matrix (Detectability)
%   Detailed explanation goes here

fh = [];

fh(end+1) = figure();
spy(FSM);
set(gca,'XTick',1:graph.numEqs);
set(gca,'XTickLabel',graph.equationAliasArray);
title('Fault Detectability Matrix');
% Reduce FSM columns to only faultable equations
faultIds = graph.getEquIdByProperty('isFaultable');
faultIndices = graph.getIndexById(faultIds);
FSM = FSM(:,faultIndices);
fh(end+1) = figure();
spy(FSM);
set(gca,'XTick',1:length(faultIndices));
set(gca,'XTickLabel',graph.equationAliasArray(faultIndices));
title('Fault detectability matrix - Faultable equations only');
% Reduce FSM columns to only detectable faults
detectionIndices = find(sum(FSM,1));
faultIndices = faultIndices(detectionIndices);
FSM = FSM(:,detectionIndices);
fh(end+1) = figure();
spy(FSM);
set(gca,'XTick',1:length(faultIndices));
set(gca,'XTickLabel',graph.equationAliasArray(faultIndices));
title('Fault detectability matrix - Detectable faults only');
end

