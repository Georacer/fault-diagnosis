%% Sensor placement analysis for examples from the paper
%  "Locating sensors in complex chemical plants based on fault 
%  diagnostic observability criteria" by Rao Raghuraj, Mani Bhushan, 
%  and Raghunathan Rengaswamy, Volume 45, Issue 2, 
%  Pages 310 - 322, AIChE.
%  
%  The paper includes two example models, one denoted
%  CSTR and one FCCU. Both examples are included in this file.
clear
close all

%% Translation of the CSTR directed graph in the paper to a 
%  structural model. The model is extended with three
%  dummy equations since faults 1, 2, and 13 is included 
%  in more than one equation. 
%
clear
model.type = 'VarStruc';
model.x = {'x14', 'x15', 'x16', 'x17', 'x18', 'x19', 'x20', 'x21', 'x22', 'x23', ...
         'x24', 'xf1', 'xf2', 'xf13'};
model.f = {'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', ...
         'f11', 'f12', 'f13'};
model.z = {};
model.rels = {...
    {'x14', 'x15', 'x20', 'x21', 'xf13'}, ...
    {'x15', 'x19', 'x20', 'x21', 'xf13', 'f6', 'f7'}, ...
    {'x15', 'x16', 'x17', 'x18', 'xf1', 'xf2'}, ...
    {'x17', 'f3'}, ...
    {'x18', 'f4', 'f5'}, ...
    {'x17', 'x18', 'x19', 'xf1', 'xf2'}, ...
    {'x20', 'x21', 'xf13', 'f12'}, ...
    {'x21', 'x22', 'xf13', 'f8'}, ...
    {'x22', 'x23', 'x24', 'f10', 'f11'}, ...
    {'x23', 'f9'}, ...
    {'x21', 'x24'}, ...
    {'xf1', 'f1'}, ...
    {'xf2', 'f2'}, ...
    {'xf13', 'f13'}};

sm = DiagnosisModel(model);
sm.name = 'CSTR example from Raghuraj et.al.';
sm.PossibleSensorLocations(model.x(1:10)); % variables 14-23 are measurable
clear model

% Plot model structure
figure(10)
sm.PlotModel();

% Perform sensor placement analysis for detectability, add first solution,
% and validate that all faults are detectable
sDet = sm.SensorPlacementDetectability();
sm2 = sm.AddSensors(sDet{1});
[df,ndf] = sm2.DetectabilityAnalysis();

% Perform sensor placement for isolability, add first solution,
% and plot isolability analysis
sIsol = sm.SensorPlacementIsolability();
sm3 = sm.AddSensors(sIsol{1});
figure(11)
sm3.IsolabilityAnalysis();

% Add sensorset suggested in Raghurajs paper
sm4 = sm.AddSensors( {'x15', 'x17', 'x18', 'x19', 'x20', 'x21', 'x23'});
figure(12)
sm4.IsolabilityAnalysis();
title('Isolability matrix for ''CSTR example from Raghuraj et.al.'' (paper sensors)')

% Plot Dulmage-Mendelsohn decomposition with canonical decomposition of the
% overdetermined part and indication of fault locations
figure(13)
sm4.PlotDM('eqclass', true, 'fault', true )

%% Example from Raghuraj et.al. FCCU model
%  Translation of the directed graph in the paper to a 
%  structural model. The model is extended with three
%  dummy equations since faults 11, 15, and 16 is included 
%  in more than one equation. 
%
clear
model.type = 'VarStruc';       
model.x = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'xf11', 'xf15', 'xf16'}; 
model.f = {'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', ...
         'R11', 'R12', 'R13', 'R14', 'R15', 'R16'};
model.z = {};
model.rels = {
    {'S1', 'S7', 'R3', 'R4', 'R5', 'R6', 'R7'}, ...
    {'S1', 'S2'}, ...
    {'S2', 'S3', 'xf11', 'xf15', 'xf16'}, ...
    {'S4', 'S5', 'xf16', 'R8', 'R9'}, ...
    {'S5', 'S6', 'xf11', 'xf15', 'xf16', 'R10', 'R14'}, ...
    {'S6', 'xf15', 'R12', 'R13'}, ...
    {'S7', 'S8', 'xf11', 'xf15'}, ...
    {'S8', 'xf15', 'xf16', 'R1', 'R2'}, ...
    {'S8', 'S9'}, ...
    {'xf11', 'R11'}, ...
    {'xf15', 'R15'}, ...
    {'xf16', 'R16'}};

sm = DiagnosisModel(model);
sm.name = 'Reduced FCCU example from Raghuraj et.al.';
sm.PossibleSensorLocations(model.x(1:9)); % variables S1-S9 are measurable
clear model

% Plot model structure
figure(20)
sm.PlotModel();

% Perform sensor placement analysis for detectability, add first solution,
% and perform detectability analysis
sDet = sm.SensorPlacementDetectability();
sm2 = sm.AddSensors(sDet{1});
[df,ndf] = sm2.DetectabilityAnalysis();

% Perform sensor placement for isolability, add first solution,
% and plot isolability abnalysis
sIsol = sm.SensorPlacementIsolability();
sm3 = sm.AddSensors(sIsol{1});
figure(21)
sm3.IsolabilityAnalysis();

% Plot Dulmage-Mendelsohn decomposition with canonical decomposition of the
% overdetermined part and indication of fault locations
figure(22)
sm3.PlotDM('eqclass', true, 'fault', true )
