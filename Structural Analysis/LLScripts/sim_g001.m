%% thrust model simulation

close all;
clear;

%% Create time vectors
dt = 0.1;
time = dt:dt:200;
fault1 = zeros(size(time));
fault1(1501:end) = 1;

deltat = zeros(size(time));
deltat(1:1000) = 0.5;
deltat(1001:end) = 0.7;

thr_r = deltat;

Va_r = zeros(size(time));
Va_r(1:1000) = 30;
Va_r(1001:end) = 40;

Vm = Va_r;
% Vm = Vm.*(1-0.8*fault1); % Insert fault at c3
Vm = Vm + 1*randn(size(time)); % Insert noise

Drag_r = 0.1*Va_r.^2;

n_r = zeros(size(time));
n_r(1:1000) = 0.6;
n_r(1001:end) = 0.7;

P_r = Drag_r.*Va_r./n_r;

k2 = 2;
w = P_r./thr_r/k2;

% hbar = hbar + 20*fault1; % insert fault at c6

thr = zeros(size(time));
P = thr;
n = thr;
Va = thr;
F = thr;
Rc5 = thr;

%% Perform calculations
for i=1:length(time)
    thr(i) = deltat(i);
    if (i>1500)
        thr(i)=0.5;
    end
    Va(i) = Vm(i);
    P(i) = thr(i)*w(i)*k2;
    n(i) = 0.1*(Va(i))^3/w(i)/deltat(i)/k2;
    F(i) = 0.1*(Va(i))^2;
    Rc5(i) = F(i)*Va(i)-P(i)*n(i);
end

%% Plot results

% Measurements
figure();
subplot(3,1,1);
plot(time,Vm);
grid on
title V_m
ylabel m/s

subplot(3,1,2);
plot(time,w);
grid on
title \omega
ylabel rad/s

subplot(3,1,3);
plot(time,deltat);
grid on
title 'throttle setting'
ylabel percent

% Calculated variables

figure();

subplot(5,1,1);
plot(time,Va);
grid on
title V_a
ylabel m/s

subplot(5,1,2);
plot(time,thr);
grid on
title 'manifold position'
ylabel percent

subplot(5,1,3);
plot(time,P);
grid on
title 'engine power'
ylabel Watt

subplot(5,1,4);
plot(time,n);
grid on
title 'propeller efficiency'
ylabel units

subplot(5,1,5);
plot(time,F);
grid on
title Thrust
ylabel N

% Residuals
figure();
subplot(1,1,1);
plot(time,Rc5);
hold on;
grid on;
title Rc5
ylabel Watts