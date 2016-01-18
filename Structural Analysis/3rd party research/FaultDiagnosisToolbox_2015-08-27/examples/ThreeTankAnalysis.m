%% Three-tank example from 
%  Diagnosability Analysis Considering Causal Interpretations 
%  for Differential Constraints, Erik Frisk, Anibal Bregon, 
%  Jan Aaslund, Mattias Krysander, Belarmino Pulido, and Gautam Biswas
%  IEEE Transactions on Systems, Man and Cybernetics, 
%  Part A: Systems and Humans (2012), Vol. 42, No. 5, 1216-1229.
% 
clear
close all

%% Define model using symbolic expressions
model.type = 'Symbolic';
model.x = {'p1','p2','p3','q0','q1','q2','q3','dp1','dp2','dp3'};
model.f = {'fV1','fV2','fV3','fT1','fT2','fT3'};
model.z = {'y1','y2','y3'};
model.parameters = {'Rv1', 'Rv2', 'Rv3', 'CT1', 'CT2', 'CT3'};

syms(model.x{:})
syms(model.f{:})
syms(model.z{:})
syms(model.parameters{:})

model.rels = {q1==1/Rv1*(p1-p2) + fV1,...
  q2==1/Rv2*(p2-p3) + fV2, ...
  q3==1/Rv3*p3 + fV3,...
  dp1==1/CT1*(q0-q1) + fT1,...
  dp2==1/CT2*(q1-q2) + fT2, ...
  dp3==1/CT3*(q2-q3) + fT3, ...
  y1==p1, y2==q2, y3==q0,...
  DiffConstraint('dp1','p1'),... % e10
  DiffConstraint('dp2','p2'),... % e11
  DiffConstraint('dp3','p3'),... % e12
};

sm = DiagnosisModel( model );
sm.name = 'Three tank system';

% clear temporary variables from workspace
clear( model.x{:} )
clear( model.f{:} )
clear( model.z{:} )
clear( model.parameters{:} )

clear model

%% Plot model
figure(10)
sm.PlotModel();

%% Isolability analysis
% Figures corresponding to Tables II, III, and IV in paper.
% Due to an error in the paper, the tables are transposed. Note that the 
% fault variable order is slightly different compared to paper

figure(20)
sm.IsolabilityAnalysis('causality','der');
title('Table II (p. 1223) - isolability with derivative causality'); 

figure(21)
sm.IsolabilityAnalysis('causality','int');
title('Table III (p. 1224) - isolability with integral causality'); 

figure(22)
sm.IsolabilityAnalysis('permute', true);
title('Table IV (p. 1224) - isolability with mixed causality'); 

%% Find set of MSO
msos = sm.MSO();

%% Use the first MSO to generate code for sequential residual generator
% Use first equation for residual equation and rest to compute unknown 
% variables
mso1 = msos{1};
Gamma = sm.Matching(mso1(2:end));
sm.SeqResGen(Gamma, mso1(1), 'seqresgen' );

%% Use the second MSO to generate code for observer based residual generator
mso2 = msos{2};
params.Rv1 = 1;
params.Rv2 = 1;
params.Rv3 = 1;
params.CT1 = 1;
params.CT2 = 1;
params.CT3 = 1;
linpoint.x0 = [0,0,0,0,0,0];
linpoint.z0 = [0;0;0];

[A,C] = sm.ObserverResGen( mso2, 'obsresgen', 'linpoint', linpoint, 'parameters', params );
K = place(A',C',[-1,-2])';



