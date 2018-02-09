%% Residual generator design/simulation for Three-tank example from paper
%  Diagnosability Analysis Considering Causal Interpretations 
%  for Differential Constraints, Erik Frisk, Anibal Bregon, 
%  Jan Aaslund, Mattias Krysander, Belarmino Pulido, and Gautam Biswas
%  IEEE Transactions on Systems, Man and Cybernetics, 
%  Part A: Systems and Humans (2012), Vol. 42, No. 5, 1216-1229.

% This version utilizes Matlab generated residual generators. For the C
% version of this script, see usecase_c.m

clear
close all

ramp = @(t,t0,t1) (t>t0).*(t<=t1).*(t-t0)./(t1-t0)+(t>t1);

%% Step 1: Define model 
modelDef.type = 'Symbolic';
modelDef.x = {'p1','p2','p3','q0','q1','q2','q3','dp1','dp2','dp3'};
modelDef.f = {'fV1','fV2','fV3','fT1','fT2','fT3'};
modelDef.z = {'y1','y2','y3'};
modelDef.parameters = {'Rv1', 'Rv2', 'Rv3', 'CT1', 'CT2', 'CT3'};

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

% Store parameter values
params.Rv1 = 1;
params.Rv2 = 1;
params.Rv3 = 1;
params.CT1 = 1;
params.CT2 = 1;
params.CT3 = 1;

clear modelDef

%% Plot model
figure(10)
model.PlotModel();

% model.BipartiteToLaTeX('bipart.tex','fault', true,'shortnames',false,...
%   'TeXNamesX',{'$p_1$', '$p_2$','$p_3$','$q_0$', '$q_1$','$q_2$','$q_3$','$\dot{p}_1$'    '$\dot{p}_2$'    '$\dot{p}_3$'},...
%   'TeXNamesE',arrayfun(@(d) sprintf('$e_{%d}$',d), 1:sm.ne, 'UniformOutput', false), ...
%   'TeXNamesF',{'$f_{V1}$', '$f_{V2}$','$f_{V3}$','$f_{T1}$','$f_{T2}$', '$f_{T3}$'});

%% Isolability analysis
figure(20)
model.IsolabilityAnalysis();

figure(21)
model.IsolabilityAnalysis('causality', 'int');

figure(22)
model.IsolabilityAnalysis('causality', 'der');

figure(23)
model.PlotDM('eqclass', true, 'fault', true );

%% Step 2: Compute MSOs and MTESs
model.CompiledMSO(0); % Ensure interpreted MSO algorithm is used
msos = model.MSO();
mtes = model.MTES();

%% Step 2: Design a few residual generators for the three-tank example

% Choose two MSOs as examples
mso1 = msos{1}; % Should be [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
mso2 = msos{2}; % Should be [1, 4, 5, 7, 8, 9, 10, 11]

% Sequential residual generator in derivative causality (no loops) (Fig. 2 in paper)
eqr1 = mso2; % all equations in the residual generator
redeq1 = 5; % residual equation
m01 = setdiff(eqr1,redeq1); % exactly determined part
Gamma1 = model.Matching(m01); % coompute matching
model.SeqResGen( Gamma1, redeq1,'ResGen1', 'implementation', 'discrete' );

% Sequential residual generator in integral causality (no loops) (Fig. 3 in paper)
eqr2 = mso2; % all equations in the residual generator
redeq2 = 7; % residual equation
m02 = setdiff(eqr2,redeq2); % exactly determined part
Gamma2 = model.Matching(m02); % compute matching
model.SeqResGen( Gamma2, redeq2,'ResGen2', 'implementation', 'discrete' );

% Sequential residual generator in mixed causality (Fig. 12 in paper)
eqr3 = mso1; % all equations in the residual generator
redeq3 = 2; % residual equation
m03 = setdiff(eqr3,redeq3); % exactly determined part
Gamma3 = model.Matching(m03);
model.SeqResGen( Gamma3, redeq3,'ResGen3', 'implementation', 'discrete' );

% Observer based residual generator based on the same equations as Resgen1
eqr4 = mso2;
linpoint.x0 = [0,0,0,0,0,0];
linpoint.z0 = [0;0;0];
[A4,C4] = model.ObserverResGen( eqr4, 'ResGen4', 'linpoint', linpoint, 'parameters', params );
K4 = place(A4',C4',[-0.2,-0.3])';

% cleanup
clear Gamma1 Gamma2 Gamma3 redeq1 redeq2 redeq3 m01 m02 m03 linpoint A4 C4

%% Step 3: Get the fault signature matrix for the four residual generators
FSM = model.FSM({mso2, mso2, mso1, mso2});
figure(30)
spy(FSM,30)
set(gca, 'YTick', 1:4, 'XTick', 1:6,...
  'YTickLabel', {'r1', 'r2', 'r3', 'r4'},'XTickLabel',model.f,...
  'box', 'off');
xlabel('Fault')
ylabel('Residual')
title('Fault Signature Matrix')

figure(31)
model.IsolabilityAnalysisFSM( FSM );

%% Step 4: Design simple controller for simulation scenarios
G = ThreeTankModel( params );

% Design simple state-feedback controller and a reference signal
Lx = lqr(G,eye(3,3),0.5);
Lr = 1/([1 0 0]*(-inv(G.A-G.B*Lx)*G.B)); % 1 gain from r to p1

ref = @(t) 0.2*sin(2*pi*1/10*t)+1;
controller = @(t,x) max(0,-Lx*x+Lr*ref(t));
clear Lx Lr

%% Step 5: Simulate scenarios {NF, Rv1, Rv2, Rv3, CT1, CT2, CT3}
noise = 0; % Set to 0/1 to turn measurement noise off/on

% Start simulation
xinit = [0 0 0]; 
fs = 10; Tend = 20;
t = (0:1/fs:Tend)'; % Output time vector

sim = cell(1,7);
sim{1} = SimScenario(0,@(t) 0, controller, params, t, xinit);
sim{2} = SimScenario(1,@(t) 0.3*ramp(t,6,10), controller, params, t, xinit);
sim{3} = SimScenario(2,@(t) 0.3*ramp(t,6,10), controller, params, t, xinit);
sim{4} = SimScenario(3,@(t) 0.3*ramp(t,6,10), controller, params, t, xinit);
sim{5} = SimScenario(4,@(t) 0.3*ramp(t,6,10), controller, params, t, xinit);
sim{6} = SimScenario(5,@(t) 0.3*ramp(t,6,10), controller, params, t, xinit);
sim{7} = SimScenario(6,@(t) 0.3*ramp(t,6,10), controller, params, t, xinit);

% Define measurements and add noise
nstd = [0.01,0,0,0,0,0.01,0]*noise;
meas = [1,6,4]; % p1, q2, q0
M = zeros(length(meas), size(sim{1}.z0,1));
M(1:length(meas),meas) = eye(length(meas));
for k=1:length(sim)
  sim{k}.z = M*sim{k}.z0 + diag(nstd(meas))*randn(length(meas),size(sim{k}.z0,2));
end

%% Plot fault free and Rv1 scenarios
figure(40)
subplot(311)
plot( sim{1}.t, sim{1}.z0(1,:), 'b', sim{1}.t, ref(sim{1}.t), 'b--', ...
  sim{1}.t, sim{1}.z0(2,:), 'r', sim{1}.t, sim{1}.z0(3,:), 'g' )
hold off
set( gca, 'box', 'off')
ylabel('Tank water pressure');
legend({'p1','p1ref', 'p2','p3'});
title('Fault free simulation (without noise)')

subplot(312)
plot( sim{1}.t, sim{1}.z0(4,:) )
set( gca, 'box', 'off')
ylabel('q0');

subplot(313)
plot( sim{1}.t, sim{1}.f)
set( gca, 'box', 'off' )
ylabel('Fault signal');
xlabel('t [s]')

% Plot scenario fRv1
figure(41)
subplot(311)
plot( sim{2}.t, sim{2}.z0(1,:), 'b', sim{2}.t, ref(sim{2}.t), 'b--', ...
  sim{2}.t, sim{2}.z0(2,:), 'r', sim{2}.t, sim{2}.z0(3,:), 'g' )

hold off
set( gca, 'box', 'off')
ylabel('Tank water pressure');
legend({'p1','p1ref','p2','p3'});
title('Fault scenario Rv1  (without noise)')

subplot(312)
plot( sim{2}.t, sim{2}.z0(4,:) )
set( gca, 'box', 'off')
ylabel('q0');

subplot(313)
plot( sim{2}.t, sim{2}.f)
set( gca, 'box', 'off' )
xlabel('t [s]');
ylabel('Fault signal');

%% Step 6: Simulate residual generators
N = length(t);
r1 = zeros(length(sim),N); % FSM: 1,4,5
r2 = zeros(length(sim),N); % FSM: 1,4,5
r3 = zeros(length(sim),N); % FSM: 2,3,4,5,6
r4 = zeros(length(sim),N); % FSM: 2,3,4,5,6

M4 = [eye(2) zeros(2,4);zeros(4,6)];
for fi=1:length(sim)
  % Simulate residual generators implemented in continuous time    
  x0 = [sim{fi}.z0(1:5,1);0]; % p1,p2,q0,q1,q2,r
%  [~,x] = ode15s(@(ts,x) ResGen4( x, interp1(sim{fi}.t,sim{fi}.z',ts), K4, params ), t, x0, odeset('Mass',M4, 'AbsTol', 1e-3));
  [~,x] = ode23t(@(ts,x) ResGen4( x, interp1(sim{fi}.t,sim{fi}.z',ts), K4, params ), t, x0, odeset('Mass',M4, 'AbsTol', 1e-3));
  r4(fi,:) = x(:,6)';
  
  % Simulate residual generators implemented in discrete time  
  state1.p1 = sim{fi}.z(1,1); state1.p2 = sim{fi}.z(2,1);
  state2.p1 = sim{fi}.z(1,1); state2.p2 = sim{fi}.z(2,1);
  state3.p1 = sim{fi}.z(1,1); state3.p2 = sim{fi}.z(2,1); state3.p3 = sim{fi}.z(3,1);
  
  for k=1:N
    [r1(fi,k), state1] = ResGen1( sim{fi}.z(:,k), state1, params, 1/fs );
    [r2(fi,k), state2] = ResGen2( sim{fi}.z(:,k), state2, params, 1/fs );
    [r3(fi,k), state3] = ResGen3( sim{fi}.z(:,k), state3, params, 1/fs );
  end
end
r1(:,1:2) = 0;
r3(:,1) = 0;

%% Plot residuals 
figure(50)
subplot(411)
plot( t, r1 )
set( gca, 'box', 'off')
title('r1 (seq/derivative/discrete)');

subplot(412)
plot( t, r2 )
set( gca, 'box', 'off')
title('r2 (seq/integral/discrete)')

subplot(413)
plot( t, r3 )
set( gca, 'box', 'off')
title('r3 (seq/mixed/discrete)');

subplot(414)
plot( t, r4 )
set( gca, 'box', 'off')
xlabel('t [s]');
title('r4 (DAE observer w. feedback/continiuous)')

