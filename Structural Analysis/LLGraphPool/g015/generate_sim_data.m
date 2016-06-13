function [readings] = generate_sim_data()
%% Generate simulation data
% Creata inputs, outputs and in-between simulation state data for testing
% the diagnostic system

inpLength = 1;
msrLength = 1;

simTime = 10;
dt = 0.1;

%% Create the I/O structure

global readings;
readings = nan*ones(simTime/dt, (inpLength+msrLength));

%% Simulate the system

time = linspace(dt,simTime,simTime/dt);

theta_c = time;

theta = theta_c;

R = 5*ones(size(time));
h = R.*theta;

k = 3*ones(size(time));
F = -k.*h;

F_m = F;

%% Fill the I/O structure

readings(:,1) = theta_c';
readings(:,2) = F_m';

end