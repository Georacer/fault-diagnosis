%% lateral model simulation

close all;
clear;

%% Create time vectors
dt = 0.1;
time = dt:dt:300;
fault1 = zeros(size(time));
fault1(1501:end) = 1;
fault2 = zeros(size(time));
fault2(2001:end) = 1;

deltaac = zeros(size(time));
deltaac(1001:1100) = 1;
deltaac(1101:1201) = -1;
deltaac(2001:2100) = -1;
deltaac(2101:2201) = 1;

deltaa_r = deltaac;
% deltaa_r = deltaa_r.*(1-fault2); % Insert fault at c1

Va_r = 30*ones(size(time));

Vm = Va_r;
% Vm = Vm.*(1-0.8*fault1); % Insert fault at c3
Vm = Vm + 1*randn(size(time)); % Insert noise

l_r = Va_r.^2.*deltaa_r;

p_r = l_r/100;

p_m = p_r;
p_m = p_m.*(1-0.8*fault1); % Insert fault at c5
p_m = p_m + 0.01*randn(size(time)); % Insert noise

% hbar = hbar + 20*fault1; % insert fault at c6

deltaa = zeros(size(time));
Va = deltaa;
p = deltaa;
l = deltaa;
Rc4 = deltaa;

%% Perform calculations
for i=1:length(time)
    deltaa(i) = deltaac(i);
    Va(i) = Vm(i);
    p(i) = p_m(i);
    l(i) = (Va(i))^2*deltaa(i);
    Rc4(i) = p(i) - l(i)/100;
end

%% Plot results

% Measurements
figure();
subplot(3,1,1);
plot(time,deltaac);
grid on
title 'aileron input'
ylabel units

subplot(3,1,2);
plot(time,Vm);
grid on
title airspeed
ylabel m/s

subplot(3,1,3);
plot(time,p_m);
grid on
title 'roll rate'
ylabel rad/s

% Calculated variables

figure();

subplot(4,1,1);
plot(time,deltaa);
grid on
title 'aileron input'
ylabel units

subplot(4,1,2);
plot(time,Va);
grid on
title airspeed
ylabel m/s

subplot(4,1,3);
plot(time,p);
grid on
title 'roll rate'
ylabel rad/s

subplot(4,1,4);
plot(time,l);
grid on
title 'rolling moment'
ylabel Nm

% Residuals
figure();
subplot(1,1,1);
plot(time,Rc4);
hold on;
grid on;
title Rc4
ylabel Nm