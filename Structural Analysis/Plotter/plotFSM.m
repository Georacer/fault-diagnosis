function [  ] = plotFSM( FSStruct )
%PLOTFSM Plot Fault Signature Matrix
%   INPUTS:
%   FSStruct: Fault Signature structure, as returned by generateFSM()

spy(FSStruct.FSM);

set(gca,'XTick', 1:length(FSStruct.fault_aliases));
set(gca,'YTick', 1:5:length(FSStruct.residual_constraints));

set(gca,'XTickLabel',FSStruct.fault_aliases);
set(gca,'YTickLabel',1:5:length(FSStruct.residual_constraints));
xtickangle(90);

title('Isolability Matrix');

end

