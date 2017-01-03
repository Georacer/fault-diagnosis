%% Small induction motor example
% The model equations are taken from 
% 
% Aguilera, F., et al. "Current-sensor fault detection and isolation 
% for induction-motor drives using a geometric approach." 
% Control Engineering Practice 53 (2016): 35-46.

clear
close all

%% Define model using symbolic expressions
fprintf('Defining model equations...\n')
modelDef.type = 'Symbolic';
modelDef.x = {'i_a','i_b','lambda_a', 'lambda_b','w', 'Tl', ...
  'di_a','di_b','dlambda_a', 'dlambda_b','dw', 'q_a', 'q_b'};
modelDef.f = {'f_a', 'f_b'};
modelDef.z = {'u_a', 'u_b', 'y1', 'y2', 'y3'};
modelDef.parameters = {'a', 'b', 'c', 'd', 'L_M', 'k','c_f', 'c_t'};
syms(modelDef.x{:})
syms(modelDef.f{:})
syms(modelDef.z{:})
syms(modelDef.parameters{:})

modelDef.rels = {...
  q_a == w*lambda_a,...
  q_b == w*lambda_b, ...
  di_a == -a*i_a + b*c*lambda_a + b*q_b+d*u_a,...
  di_b == -a*i_b + b*c*lambda_b + b*q_a+d*u_b,...
  dlambda_a == L_M*c*i_a - c*lambda_a-q_b, ...
  dlambda_b == L_M*c*i_b - c*lambda_b-q_a, ...
  dw == -k*c_f*w + k*c_t*(i_a*lambda_b - i_b*lambda_a) - k*Tl,...
  DiffConstraint('di_a','i_a'),...
  DiffConstraint('di_b','i_b'),...
  DiffConstraint('dlambda_a','lambda_a'),...
  DiffConstraint('dlambda_b','lambda_b'),...
  y1 == i_a + f_a,...
  y2 == i_b + f_b,...
  y3 == w
};

model = DiagnosisModel( modelDef );
model.name = 'Induction motor';

% clear temporary variables from workspace
clear( modelDef.x{:} )
clear( modelDef.f{:} )
clear( modelDef.z{:} )
clear( modelDef.parameters{:} )

clear modelDef
fprintf('Done!\n')

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

%% Find set of MSOS
disp('Search for MSOS sets');
model.CompiledMSO();
tic; msos = model.MSO(); toc
fprintf('Found %d MSO sets\n', numel(msos));

%% Find set of MTES
disp('Search for MTES sets');
tic; mtes = model.MTES(); toc
fprintf('Found %d MTES sets\n', numel(mtes));

%% Check observability and low index for MTES sets
oi = cellfun( @(m) model.IsObservable(m), mtes);
li = cellfun( @(m) model.IsLowIndex(m), mtes);
fprintf('Out of %d MTES sets, %d observable, %d low (structural) differential index\n', numel(mtes), sum(oi), sum(li));

%% Isolability analysis and FSM of set of MSO and MTES sets
figure(30)
subplot(121)
model.IsolabilityAnalysisArrs( msos );

FSM = model.FSM( msos );

subplot(122)
spy(FSM,30)
set(gca, 'YTick', 1:size(FSM,1), 'XTick', 1:model.nf,...
  'YTickLabel', arrayfun(@(m) sprintf('MSO%d',m), 1:numel(msos), ...
  'UniformOutput', false),'XTickLabel',model.f,...
  'box', 'off');
xlabel('Fault')
title('Fault Signature Matrix (MSO sets)')

figure(31)
subplot(121)
model.IsolabilityAnalysisArrs( mtes );
FSM = model.FSM( mtes );

subplot(122)
spy(FSM,30)
set(gca, 'YTick', 1:size(FSM,1), 'XTick', 1:model.nf,...
  'YTickLabel', arrayfun(@(m) sprintf('MTES%d',m), 1:numel(mtes), ...
  'UniformOutput', false),'XTickLabel',model.f,...
  'box', 'off');
xlabel('Fault')
title('Fault Signature Matrix (MTES sets)')

%% Sequential residual generator based on MTES1
model.MSOCausalitySweep( mtes{1} )
Gamma1 = model.Matching(setdiff(mtes{1},mtes{1}(11)));
model.SeqResGen(Gamma1, mtes{1}(11), 'IMSQResGen1' );

%% Sequential residual generator based on MTES2
model.MSOCausalitySweep( mtes{2} )
Gamma2 = model.Matching(setdiff(mtes{2},mtes{2}(6)));
model.SeqResGen(Gamma2, mtes{2}(6), 'IMSQResGen2' );

%% Observer based residual generators
model.ObserverResGen( mtes{1}, 'IMObsResGen1');
model.ObserverResGen( mtes{2}, 'IMObsResGen2');

