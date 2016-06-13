function [readings, evaluations] = generate_sim_data()
%% Generate simulation data
% Creata inputs, outputs and in-between simulation state data for testing
% the diagnostic system

inpLength = 1;
msrLength = 1;

simTime = 10;
dt = 0.01;

%% Create the I/O structure

readings = nan*ones(simTime/dt, (inpLength+msrLength));

%% Simulate the system

time = linspace(dt,simTime,simTime/dt);
x = zeros(size(time));
v = zeros(size(time));
v_dot = zeros(size(time));

u = ones(size(time));

m = 5;
k = 5;
c = 3;

for i=2:length(time)
    v_dot(i) = 1/m*(-k*x(i-1)- c*v(i-1) + u(i-1));
    v(i) = v(i-1) + v_dot(i)*dt;
    x(i) = x(i-1) + v(i)*dt;
end

x_m = x;

%% Add measurement noise

% x_m = x_m + 1*randn(size(x_m));

%% Fill the I/O structure

readings(:,1) = u';
readings(:,2) = x_m';

evaluations(:,1) = v';
evaluations(:,2) = x';
evaluations(:,3) = v';
evaluations(:,4) = v_dot';

end