%% Plot expected residual sensitivity
% * Start with a residual involving the AoS vane, if possible, as a minimum
% effort solution. However, another PSO might be more amenable (smaller,
% more interesting).

clc

%% Temporarily re-construct graphInitial

% model = g014g();
% model = g028();
% graphInitial = GraphInterface();
% graphInitial.readModel(model);
% graphInitial.createAdjacency();
% fprintf('Done building model %s\n',graphInitial.name);

%% Simulation
% * Plot responses for each fault, for 2 different operational points, with
% noise

%% Example
% * Show expected, simulated and measured residual response to the AoS
% fault, as recorded in last experiment.

load('/media/Data/Dropbox/PhD Stuff/fault-diagnosis/Structural Analysis/GraphPool/g032/dataset.mat')

% Align NKF1 and NKF2 to their ends
sample_diff = length(dataset.NKF1.Roll)-length(dataset.NKF2.VWN)+1;

Phi = dataset.NKF1.Roll(sample_diff:end);
Theta = dataset.NKF1.Pitch(sample_diff:end);
Psi = dataset.NKF1.Yaw(sample_diff:end);
Va = dataset.ARSP.Airspeed;
Alpha = dataset.CUR2.Volt-45;
Beta = dataset.CUR2.Curr-45;
Vn = dataset.NKF1.VN(sample_diff:end);
Ve = dataset.NKF1.VE(sample_diff:end);
Vd = dataset.NKF1.VD(sample_diff:end);
Vwn = dataset.NKF2.VWN;
Vwe = dataset.NKF2.VWE;
ay = dataset.IMU.AccY;
% az = dataset.IMU.AccZ;
p = dataset.IMU.GyrX;  % in rads/s
r = dataset.IMU.GyrZ;  % in rads/s

%% Calculate rotation matrix for the whole flight
eul = zeros(3,3,length(Phi));
for i=1:length(eul)
    eul(:,:,i) = eul2rotm(deg2rad([Psi(i) Theta(i) Phi(i)]));    
end

%% Calculate body-frame wind components
Vw = zeros(3,length(Phi));  % Preallocate the speeds vector
Vwd = zeros(size(Vwn));  % Assume zero vertical wind

% % First plot the 3 wind components in the inertial frame
% figure();
% plot(Vwn);
% hold on
% grid on
% plot(Vwe,'r');
% plot(Vwd,'g');
% legend({'W_n,i','W_e,i','W_d,i'});
% xlabel time
% ylabel velocity
% title('Body-frame inertial wind velocities');

% Rotate the wind component
for i=1:length(Vw)
    Vw(:,i) = eul(:,:,i)'*[Vwn(i) Vwe(i) Vwd(i)]';
end

uw = Vw(1,:);
vw = Vw(2,:);
ww = Vw(3,:);

%% Calculate body-frame inertial speeds
Vb = zeros(3,length(Phi));  % Preallocate the speeds vector
for i=1:length(Phi)
    Vb(:,i) = eul(:,:,i)'*[Vn(i) Ve(i) Vd(i)]';
end

u = Vb(1,:);
v = Vb(2,:);
w = Vb(3,:);

% figure();
% plot(u);
% hold on
% grid on
% plot(v,'r');
% plot(w,'g');
% legend({'u','v','w'});
% xlabel time
% ylabel velocity
% title('Body-frame inertial velocities');

%% Calculate relative airspeed
ur = u-uw;
vr = v-vw;
wr = w-ww;

% figure();
% plot(ur);
% hold on
% grid on
% plot(vw,'r');
% plot(wr,'g');
% legend({'u_r','v_r','w_r'});
% xlabel time
% ylabel velocity
% title('Body-frame relative airspeed');

%% Down-sample all data, based on the lowest rate (AoS);
interpolationMethod = 'linear';
extrapolation = 'extrap';

timeVec = dataset.CUR2.TimeS;
NKF1_time = dataset.NKF1.TimeS(sample_diff:end);
Phi_D = interp1(NKF1_time, Phi, timeVec, interpolationMethod, extrapolation);
Theta_D = interp1(NKF1_time, Theta, timeVec, interpolationMethod, extrapolation);
Psi_D = interp1(NKF1_time, Psi, timeVec, interpolationMethod, extrapolation);
Va_D = interp1(dataset.ARSP.TimeS, dataset.ARSP.Airspeed, timeVec, interpolationMethod, extrapolation);
Beta = dataset.CUR2.Curr-45; % This is the reference time-vector
u_D = interp1(NKF1_time, u, timeVec, interpolationMethod, extrapolation);
w_D = interp1(NKF1_time, w, timeVec, interpolationMethod, extrapolation);
ur_D = interp1(NKF1_time, ur, timeVec, interpolationMethod, extrapolation);
vr_D = interp1(NKF1_time, vr, timeVec, interpolationMethod, extrapolation);
vw_D = interp1(NKF1_time, vw, timeVec, interpolationMethod, extrapolation);
ay_D = interp1(dataset.IMU.TimeS, ay, timeVec, interpolationMethod, extrapolation);
p_D = interp1(dataset.IMU.TimeS, p, timeVec, interpolationMethod, extrapolation);
r_D = interp1(dataset.IMU.TimeS, r, timeVec, interpolationMethod, extrapolation);

%% Calculate the residual
g=9.81;
m = 12.5;
dt = [diff(timeVec)];

vr_D_est = sind(Beta).*Va_D;  % Calculate relative speed from air data
v_D = vr_D_est + vw_D;  % Calculate inertial speed from air data
temp_diff = diff(v_D);
diff_v = [0; temp_diff./dt];  % Calculate its numerical derivative
Fy = (ay_D+sind(Phi_D).*cosd(Theta_D).*g)*m;  % Calculate the lateral force
dot_v = r_D.*u_D+p_D.*w_D+Fy./m;  % Calculate the derivative of the speed from the kinematics
res = dot_v - diff_v;  % Calculate the residual as a difference of derivatives

diff_Beta = [0; diff(Beta)./dt];
Beta_est = real(asind(vr_D./Va_D));  % Calculate the AoS estimate
diff_Beta_est = [0; diff(Beta_est)./dt];
f1 = Beta-Beta_est;  % Calculate the error between estimated and measured AoS. This is the fault variable
diff_f1 = [0; diff(f1)./dt];
% res_est = 20*Va_D.*sind(f1/2).*cosd(Beta_est+f1/2);  % Calculate the expected residual as a theoretical function of the fault
res_est = Va_D.*(cosd(Beta).*deg2rad(diff_Beta) - cosd(Beta_est).*deg2rad(diff_Beta_est));  % Calculate the expected residual as a theoretical function of the fault

% % Calculate the integral of the kinematic derivative of the lateral speed
% v_est = zeros(1,length(dot_v));
% v_est(1) = v_D(1);
% for i=2:(length(v_est)-1)
%     v_est(i) = v_est(i-1)+dot_v(i)*dt(i);
% end
% res_int = v_D'-v_est;  % Calculate the residual as a difference of integrals

%% Stabilize the integration residual

% res_int_dot = diff(res_int)./dt';
% 
% res_int_stab = zeros(size(res_int));
% res_int_stab(1) = res_int(1);
% k = 0.999;
% for i=2:(length(res_int)-1)
%     res_int_stab(i) = k*res_int_stab(i-1) + res_int_dot(i)*dt(i);
% end
% 
% figure();
% plot(res_int);
% hold on
% grid on
% plot(res_int_stab,'g');

%% Plot stuff

% Plot residual constituants
figure();
plot(dot_v);
hold on
grid on
plot(diff_v,'g');
plot(f1,'r');
legend({'Kinematic derivative','Numerical Derivative','Error'});

% Residual plot vs error
figure();
entries = {};
hold on
grid on
plot(abs(res),'b');
entries{end+1} = 'Residual via differentiation';
% plot(abs(res_est),'g');
% entries{end+1} = 'Expected Residual';
plot(abs(f1),'r');
entries{end+1} = 'Fault magnitude';
title('Residuals and error');
legend(entries);
ylim([0 500]);

% Beta values
figure();
plot(Beta);
hold on
grid on
plot(Beta_est,'g');
title('\beta (Angle of Sideslip)');
plot(f1,'r');
legend({'Measured AoS','Estimated AoS','Error'});
