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
modelDef.type = 'Symbolic';
modelDef.x = {'p1','p2','p3','q0','q1','q2','q3','dp1','dp2','dp3'};
modelDef.x_latex = {'p_1','p_2','p_3','q_0','q_1','q_2','q_3','\dot{p}_1','\dot{p}_2','\dot{p}_3'};

modelDef.f = {'fV1','fV2','fV3','fT1','fT2','fT3'};
modelDef.f_latex = {'f_{V1}','f_{V2}','f_{V3}','f_{T1}','f_{T2}','f_{T3}'};

modelDef.z = {'y1','y2','y3'};
modelDef.z_latex = {'y_1','y_2','y_3'};

modelDef.parameters = {'Rv1', 'Rv2', 'Rv3', 'CT1', 'CT2', 'CT3'};
modelDef.parameters_latex = {'R_{v1}', 'R_{v2}', 'R_{v3}', 'C_{T1}', 'C_{T2}', 'C_{T3}'};

syms(modelDef.x{:})
syms(modelDef.f{:})
syms(modelDef.z{:})
syms(modelDef.parameters{:})

modelDef.rels = {q1==1/Rv1*(p1-p2) + fV1,...
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

model = DiagnosisModel( modelDef );
model.name = 'Three tank system';

% clear temporary variables from workspace
clear( modelDef.x{:} )
clear( modelDef.f{:} )
clear( modelDef.z{:} )
clear( modelDef.parameters{:} )

clear modelDef

%% Plot model
figure(10)
model.PlotModel();
%model.PlotModel('Export_LaTeX', 'tankmodel.tex'); % Export to LaTeX file

%% Isolability analysis
% Figures corresponding to Tables II, III, and IV in paper.
% Due to an error in the paper, the tables are transposed. Note that the 
% fault variable order is slightly different compared to paper

figure(20)
model.IsolabilityAnalysis('causality','der');
title('Table II (p. 1223) - isolability with derivative causality'); 

figure(21)
model.IsolabilityAnalysis('causality','int');
title('Table III (p. 1224) - isolability with integral causality'); 

figure(22)
model.IsolabilityAnalysis('permute', true);
title('Table IV (p. 1224) - isolability with mixed causality'); 

%model.IsolabilityAnalysis('causality','mixed','Export_LaTeX', 'isolanalysis.tex');

%% Find set of MSO
msos = model.MSO();

%% Use the first MSO to generate code for sequential residual generator
% Use first equation for residual equation and rest to compute unknown 
% variables
mso1 = msos{1};

model.IsLowIndex(mso1(2:end)) % Confirm that this is a high-index problem
model.Pantelides(mso1(2:end)) % How high? Structural index is 2

Gamma = model.Matching(mso1(2:end));
figure(30)
model.PlotMatching(Gamma)

model.SeqResGen(Gamma, mso1(1), 'seqresgen' );

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

[A,C] = model.ObserverResGen( mso2, 'obsresgen', 'linpoint', linpoint, 'parameters', params );
K = place(A',C',[-1,-2])';



