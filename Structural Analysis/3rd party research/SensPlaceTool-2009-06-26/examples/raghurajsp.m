%%%%%% Sensor placement analysis for examples from the paper
%%%%%% "Locating sensors in complex chemical plants based on fault 
%%%%%% diagnostic observability criteria" by Rao Raghuraj, Mani Bhushan, 
%%%%%% and Raghunathan Rengaswamy, Volume 45, Issue 2 , 
%%%%%% Pages 310 - 322, AIChE.
%%%%%% 
%%%%%% The paper includes two example models, one denoted
%%%%%% CSTR and one FCCU. Both examples are included in this file.

%% Translation of the CSTR directed graph in the paper to a 
%  structural model. The model is extended with three
%  dummy equations since faults 1, 2, and 13 is included 
%  in more than one equation. 
%
%                              x
%                          x x f
%    1 1 1 1 1 1 2 2 2 2 2 f f 1
%    4 5 6 7 8 9 0 1 2 3 4 1 2 3
X = [1 1 0 0 0 0 1 1 0 0 0 0 0 1;... % 14
     0 1 0 0 0 1 1 1 0 0 0 0 0 1;... % 15
     0 1 1 1 1 0 0 0 0 0 0 1 1 0;... % 16
     0 0 0 1 0 0 0 0 0 0 0 0 0 0;... % 17
     0 0 0 0 1 0 0 0 0 0 0 0 0 0;... % 18
     0 0 0 1 1 1 0 0 0 0 0 1 1 0;... % 19
     0 0 0 0 0 0 1 1 0 0 0 0 0 1;... % 20
     0 0 0 0 0 0 0 1 1 0 0 0 0 1;... % 21
     0 0 0 0 0 0 0 0 1 1 1 0 0 0;... % 22
     0 0 0 0 0 0 0 0 0 1 0 0 0 0;... % 23
     0 0 0 0 0 0 0 1 0 0 1 0 0 0;... % 24
     0 0 0 0 0 0 0 0 0 0 0 1 0 0;... % dummy equation for fault 1
     0 0 0 0 0 0 0 0 0 0 0 0 1 0;... % dummy equation for fault 2
     0 0 0 0 0 0 0 0 0 0 0 0 0 1];   % dummy equation for fault 13

%                      1 1 1 1
%    1 2 3 4 5 6 7 8 9 0 1 2 3
F = [0 0 0 0 0 0 0 0 0 0 0 0 0;... % 14
     0 0 0 0 0 1 1 0 0 0 0 0 0;... % 15
     0 0 0 0 0 0 0 0 0 0 0 0 0;... % 16
     0 0 1 0 0 0 0 0 0 0 0 0 0;... % 17
     0 0 0 1 1 0 0 0 0 0 0 0 0;... % 18
     0 0 0 0 0 0 0 0 0 0 0 0 0;... % 19
     0 0 0 0 0 0 0 0 0 0 0 1 0;... % 20
     0 0 0 0 0 0 0 1 0 0 0 0 0;... % 21
     0 0 0 0 0 0 0 0 0 1 1 0 0;... % 22
     0 0 0 0 0 0 0 0 1 0 0 0 0;... % 23
     0 0 0 0 0 0 0 0 0 0 0 0 0;... % 24
     1 0 0 0 0 0 0 0 0 0 0 0 0;... % dummy equation for fault 1
     0 1 0 0 0 0 0 0 0 0 0 0 0;... % dummy equation for fault 2
     0 0 0 0 0 0 0 0 0 0 0 0 1];   % dummy equation for fault 13

xnames = {'14', '15', '16', '17', '18', '19', '20', '21', '22', '23', ...
         '24', 'xf1', 'xf2', 'xf13'};
fnames = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', ...
         '11', '12', '13'};
relnames = xnames;
SM = CreateSM(X,F,[],relnames,xnames,fnames);
SM.name = 'CSTR example from Raghuraj et.al.';
svar = SM.x(1:10); % variables 14-23 are measurable

%fadd = 1;
fadd = 0;

%%% Perform sensor placement analysis for detectability
Dfd = SensPlaceDetSM(SM,svar,SM.f);
detsens = MinimalSPSets(Dfd);

SMdet = AddSensorsSM(SM,detsens{2},fadd);
[imdet,ndfdet,dfdet] = IsolabilityAnalysisSM(SMdet);

%%% Perform sensor placement for isolability
senssets = SensPlaceIsolSM(SM,svar,fadd);

% Add sensors from sensor placement analysis
SMb = AddSensorsSM(SM,senssets{1},fadd);

[imb,ndfb,dfb] = IsolabilityAnalysisSM(SMb);

% Add sensorset suggested in Raghurajs paper
papersensset = {'15', '17', '18', '19', '20', '21', '23'};
SMc = AddSensorsSM(SM,papersensset,fadd);
[imc,ndfc,dfc] = IsolabilityAnalysisSM(SMc);

%% Example from Raghuraj et.al. FCCU model
%  Translation of the directed graph in the paper to a 
%  structural model. The model is extended with three
%  dummy equations since faults 11, 15, and 16 is included 
%  in more than one equation. 
%
%                      x x x
%                      f f f
%                      1 1 1
%    1 2 3 4 5 6 7 8 9 1 5 6
X = [1 0 0 0 0 0 1 0 0 0 0 0;...  % s1
     1 1 0 0 0 0 0 0 0 0 0 0;...  % s2
     0 1 1 0 0 0 0 0 0 1 1 1;...  % s3
     0 0 0 1 1 0 0 0 0 0 0 1;...  % s4
     0 0 0 0 1 1 0 0 0 1 1 1;...  % s5
     0 0 0 0 0 1 0 0 0 0 1 0;...  % s6
     0 0 0 0 0 0 1 1 0 1 1 0;...  % s7
     0 0 0 0 0 0 0 1 0 0 1 1;...  % s8
     0 0 0 0 0 0 0 1 1 0 0 0;...  % s9
     0 0 0 0 0 0 0 0 0 1 0 0;...  % xf11
     0 0 0 0 0 0 0 0 0 0 1 0;...  % xf15
     0 0 0 0 0 0 0 0 0 0 0 1];    % xf16

%                      1 1 1 1 1 1 1
%    1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6
F = [0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0;... % s1
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % s2
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % s3
     0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0;... % s4
     0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0;... % s5
     0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0;... % s6
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % s7
     1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % s8
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % s9
     0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;... % xf11
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;... % xf15
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];   % xf16
     
xnames = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'xf11', 'xf15', 'xf16'}; 
fnames = {'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', ...
         'R11', 'R12', 'R13', 'R14', 'R15', 'R16'};
relnames = xnames;
SM = CreateSM(X,F,[],relnames,xnames,fnames);
SM.name = 'Reduced FCCU example from Raghuraj et.al.';
svar = SM.x(1:9); % variables S1-S9 are measurable

%fadd = 1;
fadd = 0;

%%% Perform sensor placement analysis for detectability
Dfd = SensPlaceDetSM(SM,svar,SM.f);
detsens = MinimalSPSets(Dfd);

SMdet = AddSensorsSM(SM,detsens{1},fadd);
[imdet,ndfdet,dfdet] = IsolabilityAnalysisSM(SMdet);

%%% Perform sensor placement for isolability
senssets = SensPlaceIsolSM(SM,svar,fadd);

% Add sensors from sensor placement analysis
SMb = AddSensorsSM(SM,senssets{1},fadd);

[imb,ndfb,dfb] = IsolabilityAnalysisSM(SMb);

