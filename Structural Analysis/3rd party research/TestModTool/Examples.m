clc
clear all
addpath('src')

%% Introductory example in the DX-paper

% Unknown variables
Xvar = {'x1','x2','x3'};

% Faults
Fvar = {'f1', 'f2', 'f3', 'f4', 'f5'};

% Known variables
Zvar = {};

% Define structure
% Each line represents a model relation and lists all involved variables. 
relsX = {...
    {'x1','f1'}, ... %e1
    {'x1','x2','x3','f2'}, ... %e2
    {'x2','x3'}, ... %e3
    {'x2','f3'}, ... %e4
    {'x2', 'f4'},... % e5    
    {'x3', 'f5'}... % e6
};
   
% Compute the incidence matrices
X = symbdef(relsX, Xvar)>0;
F = symbdef(relsX, Fvar)>0;
Z = symbdef(relsX, Zvar)>0;

% Build SM object
SM      = CreateSM(X,F,Z,{},Xvar,Fvar,Zvar); 
SM.name = 'Introductory example';

%% Plot Model
figure(1)
PlotSM(SM)

%% Apply MTES and TES-algorithm
Ex1MTES = MTES(SM);
Ex1TES = TES(SM);
Ex1PSO = PSO(SM);
Ex1MSO = MSO(SM);

%% Three-tank example

% Unknown variables
Xvar = {'q0', 'q1', 'q2', 'q3', 'qp', 'p0', 'p1', 'p2', 'p3','pf'};

% Faults
Fvar = {'fv1', 'fv2', 'fv3', 'fc1', 'fc2', 'fc3','fpipe'};

% Known variables
Zvar = {'y1', 'y2', 'y3'};

% Define structure
% Each line represents a model relation and lists all involved variables. 
relsX = {...
    {'qp','p0','fpipe'}, ... %e1
    {'qp','q0'}, ... %e2
    {'pf','p0','p1'}, ... %e3
    {'q0','pf'}, ... %e4
    {'q1', 'p1', 'p2', 'fv1'},... % e5    
    {'q2', 'p2', 'p3', 'fv2'},... % e6
    {'q3', 'p3', 'fv3'},... % e7
    {'q0', 'q1', 'p1', 'fc1'},... % e8
    {'q1', 'q2', 'p2', 'fc2'},... % e9
    {'q2', 'q3', 'p3', 'fc3'},... % e10
    {'q0', 'y1'},... % e11
    {'p1', 'y2'},... % e12
    {'q3', 'y3'},... % e13
    {'p3', 'y4'},... % e14
    {'Rv0','y2'},... % e15
};

% Compute the incidence matrices
X = symbdef(relsX, Xvar)>0;
F = symbdef(relsX, Fvar)>0;
Z = symbdef(relsX, Zvar)>0;

% Build SM object
SM      = CreateSM(X,F,Z,{},Xvar,Fvar,Zvar); 
SM.name = 'Three-tank case study';

%% Plot Model
figure(2)
PlotSM(SM);

%% Apply MTES and TES-algorithm
Ex2MTES = MTES(SM);
Ex2TES = TES(SM);
Ex2PSO = PSO(SM);
Ex2MSO = MSO(SM);

%% Engine example
load engine

%% Plot Model
figure(3)
PlotSM(SM);

%% Apply MTES and TES-algorithm
Ex3MTES = MTES(SM);
Ex3TES = TES(SM);
Ex3PSO = PSO(SM);
Ex3MSO = MSO(SM);
