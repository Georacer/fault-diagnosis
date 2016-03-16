%% Sensor placement analysis of the linear system from 
%  Mattias, Krysander and Erik Frisk, "Sensor placement for fault 
%  diagnosis." IEEE Transactions on Systems, Man and Cybernetics, 
%  Part A: Systems and Humans (2008): 1398-1410.
% 
clear 
close all
%% Define model structure and create model object
% x1' = -x1+x2+x5
% x2' = -2x2+x3+x4
% x3' = -3x3+x5 + f1 + f2
% x4' = -4x4 + x5 + f3
% x5' = -5x5 + u + f4

modelDef.type = 'MatrixStruc';
modelDef.X = [1 1 0 0 1;0 1 1 1 0;0 0 1 0 1;0 0 0 1 1;0 0 0 0 1];
modelDef.F = [0 0 0 0;...
     0 0 0 0;...
     1 1 0 0;...
     0 0 1 0;...
     0 0 0 1];
modelDef.Z = [];
model = DiagnosisModel(modelDef);   
model.name = 'Small linear model';

clear modelDef

%% Plot model structure
figure(1)
model.PlotModel();

%% Perform sensor placement analysis for detectability
%  of all faults

sDet = model.SensorPlacementDetectability();

% Add first solution and perform detectability analysis
model2 = model.AddSensors(sDet{1});
[df,ndf] = model2.DetectabilityAnalysis();

%% Perform sensor placement analysis for maximum 
%  fault isolability
model.SensorLocationsWithFaults(1:5); % Set all new sensors may become faulty
sIsol = model.SensorPlacementIsolability();

% add the first solution and perform isolability analysis
model3 = model.AddSensors(sIsol{1});

figure(2)
model3.IsolabilityAnalysis();

% Plot the Dulmage-Mendelsohn decomposition of the extended system
figure(3)
model3.PlotDM('eqclass',true, 'fault', true)
