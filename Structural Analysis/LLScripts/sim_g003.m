%% Longitudinal model simulation

close all;
clear;

%% Create time vectors
dt = 0.1;
time = dt:dt:300;
fault1 = zeros(size(time));
fault2 = fault1;
fault1(1501:end) = 1;
fault2(2501:end) = 1;

hbar = zeros(size(time));
hbar(1:2000) = 200;
hbar(2001:end) = 200+200*(time(2001:end)-time(2001))/(time(3000)-time(2001));
h_r = hbar;

% hbar = hbar + 20*fault1; % insert fault at c6
hbar = hbar + 0.1*randn(size(time)); % Insert noise

Va_r = zeros(size(time));
Va_r(1:1000) = 30;
Va_r(1001:end) = 40;

Vam = Va_r./(1+h_r/1000);
Vam = Vam.*(1-0.8*fault1); % Insert fault at c7
Vam = Vam + 1*randn(size(time)); % Insert noise

theta_r = zeros(size(time));
theta_r(2001:end) = asind(2/Va_r(end));

Vggps = Va_r.*cosd(theta_r);
Vggps = Vggps + 1*randn(size(time)); % Insert noise

hgps = h_r;
% hgps = hgps + 100*fault1; % Insert fault at c4
hgps = hgps + 5*randn(size(time)); % Insert noise

thetam = theta_r;
% thetam = thetam.*(1-fault2); % Insert fault at c8
thetam = thetam + 0.5*randn(size(time)); % Insert noise

h = zeros(size(time));
Vg = h;
hdot = h;
Va = h;
theta = h;
Rc6 = h;
Rc2 = h;
Rc7 = h;

%% Perform calculations
for i=1:length(time)
    h(i) = hgps(i);
    Vg(i) = Vggps(i);
    theta(i) = thetam(i);
    Rc6(i) = h(i)-hbar(i);
    if (i>1)
        hdot(i) = (h(i)-h(i-1))/dt;
    end
    Va(i) = Vg(i)/cosd(theta(i));
    Rc7(i) = Va(i) - Vam(i)*(1+h(i)/1000);
    Rc2(i) = Va(i)*sind(theta(i)) - hdot(i);
end

%% Plot results

% Measurements
figure();
subplot(5,1,1);
plot(time,thetam);
grid on
title \theta_m
ylabel degrees

subplot(5,1,2);
plot(time,Vam);
grid on
title Vam
ylabel m/s

subplot(5,1,3);
plot(time,hbar);
grid on
title hbar
ylabel m

subplot(5,1,4);
plot(time,Vggps);
grid on
title Vggps
ylabel m/s

subplot(5,1,5);
plot(time,hgps);
grid on
title hgps
ylabel m

% Calculated variables

figure();

subplot(5,1,1);
plot(time,h);
grid on
title h
ylabel m

subplot(5,1,2);
plot(time,Vg);
grid on
title Vg
ylabel m/s

subplot(5,1,3);
plot(time,theta);
grid on
title \theta
ylabel degrees

subplot(5,1,4);
plot(time,hdot);
grid on
title hdot
ylabel m/s

subplot(5,1,5);
plot(time,Va);
grid on
title Va
ylabel m/s

% Residuals
figure();
subplot(3,1,1);
plot(time,Rc2);
hold on;
grid on;
title RC2
ylabel m/s

subplot(3,1,2);
plot(time,Rc6);
hold on;
grid on;
title RC6
ylabel m

subplot(3,1,3);
plot(time,Rc7);
hold on;
grid on;
title RC7
ylabel m/s