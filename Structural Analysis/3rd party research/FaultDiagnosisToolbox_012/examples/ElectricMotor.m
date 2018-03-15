%% Simple electric motor example
clear
close all

%% Define model using symbolic expressions
modelDef.type = 'Symbolic';
modelDef.x = {'dI','dw','dth', 'I','w','th','alpha','DT','Tm','Tl'};
modelDef.f = {'fR','fi','fw','fD'};
modelDef.z = {'V','yi','yw','yd'};
modelDef.parameters = {'Ka','b','R','J','L'};

syms(modelDef.x{:})
syms(modelDef.f{:})
syms(modelDef.z{:})
syms(modelDef.parameters{:})

modelDef.rels = {...
  V == I*(R+fR) + L*dI + Ka*I*w,... % e1
  Tm == Ka*I^2, ...                 % e2
  J*dw == DT-b*w, ...               % e3
  DT == Tm-Tl, ...                  % e4
  dth == w, ...                     % e5
  dw == alpha, ...                  % e6
  yi == I + fi, ...                 % e7
  yw == w + fw, ...                 % e8
  yd == DT + fD, ...                % e9
  DiffConstraint('dI','I'),...      % e10
  DiffConstraint('dw','w'),...      % e11
  DiffConstraint('dth','th'),...    % e12
};

modelDef.x_latex = {'\dot{I}', '\dot\omega' '\dot\theta' 'I'  '\omega'  '\theta'  '\alpha'  'T'  'T_m'  'T_l'};
modelDef.f_latex = {'f_R'  'f_i'  'f_\omega'  'f_D'};

model = DiagnosisModel( modelDef );
model.name = 'Electric motor';

% clear temporary variables from workspace
clear( modelDef.x{:} )
clear( modelDef.f{:} )
clear( modelDef.z{:} )
clear( modelDef.parameters{:} )

clear modelDef

%% Generate bipartite graph figure in LaTeX 
model.BipartiteToLaTeX('EMbipartite', 'shortname', false, 'faults', true);

%% Explore model
model.Lint()

figure(10)
model.PlotModel();

%% Isolability analysis
figure(20)
model.IsolabilityAnalysis('causality','der');
title('Isolability with derivative causality'); 

figure(21)
model.IsolabilityAnalysis('causality','int');
title('Isolability with integral causality'); 

figure(22)
model.IsolabilityAnalysis();
title('Isolability with mixed causality'); 

figure(23)
model.PlotDM('eqclass', true, 'fault', true)

%% Compute set of MSOs
msos = model.MSO();

%% Isolability analysis and FSM of set of MSOs
figure(30)
model.IsolabilityAnalysisArrs( msos );
FSM = model.FSM( msos );

figure(31)
spy(FSM,30)
set(gca, 'YTick', 1:size(FSM,1), 'XTick', 1:model.nf,...
  'YTickLabel', {'MSO1', 'MSO2', 'MSO3'},'XTickLabel',model.f,...
  'box', 'off');
xlabel('Fault')
title('Fault Signature Matrix')

%% Residual generators based on MSO1
model.MSOCausalitySweep( msos{1} )

Gamma11 = model.Matching(setdiff(msos{1},msos{1}(1)));
model.SeqResGen(Gamma11, msos{1}(1), 'EMSQResGen11' );

Gamma12 = model.Matching(setdiff(msos{1},msos{1}(2)));
model.SeqResGen(Gamma12, msos{1}(2), 'EMSQResGen12' );

Gamma13 = model.Matching(setdiff(msos{1},msos{1}(3)));
model.SeqResGen(Gamma13, msos{1}(3), 'EMSQResGen13' );

Gamma14 = model.Matching(setdiff(msos{1},msos{1}(4)));
model.SeqResGen(Gamma14, msos{1}(4), 'EMSQResGen14', 'diffres', 'Der' );


%% Residual generators based on MSO2
model.MSOCausalitySweep( msos{2} )

Gamma21 = model.Matching(setdiff(msos{2},msos{2}(1)));
model.SeqResGen(Gamma21, msos{2}(1), 'EMSQResGen21' );

Gamma22 = model.Matching(setdiff(msos{2},msos{2}(3)));
model.SeqResGen(Gamma22, msos{2}(3), 'EMSQResGen22' );

Gamma23 = model.Matching(setdiff(msos{2},msos{2}(4)));
model.SeqResGen(Gamma23, msos{2}(4), 'EMSQResGen23' );

Gamma24 = model.Matching(setdiff(msos{2},msos{2}(2)));
model.SeqResGen(Gamma24, msos{2}(2), 'EMSQResGen24' );

%% Residual generators based on MSO3
model.MSOCausalitySweep( msos{3} )

Gamma31 = model.Matching(setdiff(msos{3},msos{3}(1)));
model.SeqResGen(Gamma31, msos{3}(1), 'EMSQResGen31' );

Gamma32 = model.Matching(setdiff(msos{3},msos{3}(3)));
model.SeqResGen(Gamma32, msos{3}(3), 'EMSQResGen32' );

Gamma33 = model.Matching(setdiff(msos{3},msos{3}(4)));
model.SeqResGen(Gamma33, msos{3}(4), 'EMSQResGen33' );

Gamma34 = model.Matching(setdiff(msos{3},msos{3}(6)));
model.SeqResGen(Gamma34, msos{3}(6), 'EMSQResGen34' );

Gamma35 = model.Matching(setdiff(msos{3},msos{3}(2)));
model.SeqResGen(Gamma35, msos{3}(2), 'EMSQResGen35' );

Gamma36 = model.Matching(setdiff(msos{3},msos{3}(5)));
model.SeqResGen(Gamma36, msos{3}(5), 'EMSQResGen36' );

%% Observer based residual generators
cellfun( @(m) ~model.IsHighIndex(m), msos) % Verify that all MSOs are low-index

model.ObserverResGen( msos{1}, 'EMObsResGen1');
model.ObserverResGen( msos{2}, 'EMObsResGen2');
model.ObserverResGen( msos{3}, 'EMObsResGen3');

