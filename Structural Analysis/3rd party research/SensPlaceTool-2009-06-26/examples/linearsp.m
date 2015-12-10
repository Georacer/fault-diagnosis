%%%%% Sensor placement analysis of a linear system
%%%%% with model equations 
%%%%% 
%%%%% x1' = -x1+x2+x5
%%%%% x2' = -2x2+x3+x4
%%%%% x3' = -3x3+x5 + f1 + f2
%%%%% x4' = -4x4 + x5 + f3
%%%%% x5' = -5x5 + u + f4
     
%% Define model structure and create SM-object
X = [1 1 0 0 1;0 1 1 1 0;0 0 1 0 1;0 0 0 1 1;0 0 0 0 1];
F = [0 0 0 0;...
     0 0 0 0;...
     1 1 0 0;...
     0 0 1 0;...
     0 0 0 1];
SM = CreateSM(X,F);
SM.name = 'Small linear model';
%PlotSM(SM);

% Define variables that can be measured, here all state
% variables can be measured
svar = SM.x;

%% Perform sensor placement analysis for detectability
%  of all faults
Dfdet = SensPlaceDetSM(SM,svar,SM.f);

% convert the detectability sets into sensor sets
senssetdet = MinimalSPSets(Dfdet); 

%% Perform sensor placement analysis for maximum 
%  fault isolability

%fadd = 1;  % Newly added sensors can become faulty
fadd = 0; % Newly added sensors can not become faulty
senssets = SensPlaceIsolSM(SM,svar,fadd);

%% Add the first minimal sensor set to the model and
%  perform a new isolability analysis to verify the results
SMb = AddSensorsSM(SM,senssets{1},fadd);

[imb,ndfb,dfb] = IsolabilityAnalysisSM(SMb);
