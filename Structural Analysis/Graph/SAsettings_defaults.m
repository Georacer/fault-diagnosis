function [ SAsettings ] = SAsettings_defaults(  )
%SASETTINGS_DEFAULTS Generate default settings structure for structural_analysis function

SAsettings.matchMethod = 'BBILP';
SAsettings.SOType = 'MTES';
SAsettings.branchMethod = 'DFS';
SAsettings.maxMSOsExamined = 0;
SAsettings.exitAtFirstValid = false;
SAsettings.maxSearchTime = inf;  % Maximum search time for a matching in each PSO
SAsettings.plotGraphInitial = false;
SAsettings.plotGraphOver = false;
SAsettings.plotGraphRemaining = false;
SAsettings.plotGraphDisconnected = false;
SAsettings.plotGraphPSO = false;
SAsettings.plotGraphMatched = false;

end

