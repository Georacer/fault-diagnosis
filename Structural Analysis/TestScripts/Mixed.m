clear;
close all hidden;

% Select the models to test
% model = g005a(); % UAV model described in Fravolini, M., Campa, G., & Napolitano, M. (2008).
model = g040(); % UAV model described in Fravolini, M., Campa, G., & Napolitano, M. (2008).

% model = g039(); % Monitorable system from V. Flaugergues2009

matchMethod = 'Mixed';

% Define the Structurally Overdetermined set of graphs to examine
SOType = 'MTES';

% The branch selection strategy for BBILP will be Depth-First Search
branchMethod = 'DFS';

%% Start program execution

% Build the options structure
SA_settings.matchMethod = matchMethod;
SA_settings.SOType = SOType;
SA_settings.branchMethod = branchMethod;
SA_settings.maxMSOsExamined = 1;
SA_settings.matchingsPerMSO = 1; % Default 0, sets to max
SA_settings.plotGraphInitial = false;
SA_settings.plotGraphOver = false;
SA_settings.plotGraphRemaining = true;
SA_settings.plotGraphDisconnected = false;
SA_settings.plotGraphPSO = false;
SA_settings.plotGraphMatched = true;

%% Perform Structural Analsysis and Matching, extract residual generators
SA_results = structural_analysis(model, SA_settings);