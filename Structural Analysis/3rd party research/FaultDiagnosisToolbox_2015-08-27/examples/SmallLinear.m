%% Sensor placement analysis of the linear system from 
%  Mattias, Krysander and Erik Frisk, "Sensor placement for fault 
%  diagnosis." IEEE Transactions on Systems, Man and Cybernetics, 
%  Part A: Systems and Humans (2008): 1398-1410.
% 
clear 
close all
%% Define model structure and create SM-object
% x1' = -x1+x2+x5
% x2' = -2x2+x3+x4
% x3' = -3x3+x5 + f1 + f2
% x4' = -4x4 + x5 + f3
% x5' = -5x5 + u + f4

model.type = 'MatrixStruc';
model.X = [1 1 0 0 1;0 1 1 1 0;0 0 1 0 1;0 0 0 1 1;0 0 0 0 1];
model.F = [0 0 0 0;...
     0 0 0 0;...
     1 1 0 0;...
     0 0 1 0;...
     0 0 0 1];
model.Z = [];
sm = DiagnosisModel(model);   
sm.name = 'Small linear model';

clear model

%% Plot model structure
figure(1)
sm.PlotModel();

%% Perform sensor placement analysis for detectability
%  of all faults

sDet = sm.SensorPlacementDetectability();

% Add first solution and perform detectability analysis
sm2 = sm.AddSensors(sDet{1});
[df,ndf] = sm2.DetectabilityAnalysis();

%% Perform sensor placement analysis for maximum 
%  fault isolability
sm.SensorLocationsWithFaults(1:5); % Set all new sensors may become faulty
sIsol = sm.SensorPlacementIsolability();

% add the first solution and perform isolability analysis
sm3 = sm.AddSensors(sIsol{1});

figure(2)
sm3.IsolabilityAnalysis();

% Plot the Dulmage-Mendelsohn decomposition of the extended system
figure(3)
sm3.PlotDM('eqclass',true, 'fault', true)
