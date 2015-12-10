%%%%% Sensor placement analysis of the model of the DAMADICS 
%%%%% benchmark valve

%% Define structural model
% Unknown variables
Xvar = {'x', 'xh', 'Ps', 'P1', 'P2', 'Pz',...
	'Pv', 'DeltaP', 'DeltaP-a', ...
	'Q', 'Qv', 'Qv3', 'Qc', 'T1', 'Fvc', 'xf10'};

% Faults
Fvar = {'f1', 'f4', 'f5', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12', ...
	'f13', 'f16', 'f18'};

% Known variables
Zvar = {'Yx', 'YP1', 'YP2', 'CVI', 'Cv', 'x3'};

% Define structure
% Each line represents a model relation and lists all involved variables. 
rels = {...
    {'Ps', 'xf10', 'x', 'f4', 'f11', 'Fvc'},... % e1
    {'xh', 'x', 'f8'},... % e2
    {'Qv', 'f5', 'f1', 'xh', 'DeltaP'},... % e3
    {'DeltaP-a', 'xh', 'P1', 'Pv'},... % e4
    {'Pv', 'T1'},... % e5
    {'DeltaP', 'P1', 'P2', 'DeltaP-a'},... % e6
    {'Fvc', 'P1', 'xh', 'P2', 'DeltaP-a','Pv'},... % e7
    {'Qv3', 'x3', 'f18', 'P1', 'P2'},... % e8
    {'Qc', 'Ps', 'xh'},... % e9
    {'Qc', 'f9', 'Ps', 'xf10', 'CVI', 'Pz', 'f16'},... % e10
    {'Q', 'Qv', 'Qv3'},... % e11
    {'Yx', 'xh', 'f13'},... % e12
    {'YP1', 'P1'},... % e14
    {'YP2', 'P2'},... % e15
    {'T1', 'f7'},... % e18
    {'CVI', 'f12', 'Cv', 'Yx'},... % e19
    {'xf10', 'f10'},... % e20 - dummy equation for fault f10
};

% Compute the incidence matrices
X = symbdef(rels, Xvar)>0;
F = symbdef(rels, Fvar)>0;
Z = symbdef(rels, Zvar)>0;

% Build SM object
SM      = CreateSM(X,F,Z,{},Xvar,Fvar,Zvar); 
SM.name = 'Structural model of the Damadics benchmark';
%% Plot Model
figure(1)
PlotSM(SM);

%% Perform isolability analysis
figure(2)
[im,ndf,df] = IsolabilityAnalysisSM(SM);
[p,q,r,s] = dmperm(im); spy(im(p,q),40);

%% Perform sensor placement analysis 
% achive detectability
svar = SM.x(1:15); % all variables but dummy-variable xf10 measureable
fadd = svar; % possible faults in all new sensor positions

Dfd = SensPlaceDetSM(SM,svar,SM.f);
detsens = MinimalSPSets(Dfd);
SMd = AddSensorsSM(SM,detsens{2},fadd);
[imd,ndfd,dfd] = IsolabilityAnalysisSM(SMd);

%% achieve full fault isolability
senssets = SensPlaceIsolSM(SM,svar,fadd);

% add set of sensors and redo isolability analysis
% to verify results

SMb = AddSensorsSM(SM,senssets{1},fadd);

figure(3)
PlotSM(SMb);

[imb,ndfb,dfb] = IsolabilityAnalysisSM(SMb);
figure(4)
[p,q,r,s] = dmperm(imb); spy(imb(p,q),40);
