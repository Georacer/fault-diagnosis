%% FAULT_RESPONSE_DEMO Demo script for the fault response levels estimations

% This script involves
% * Generation of the Structural Model
% * Automated generation of the residual generator
% * Estimation of the Fault Response Magnitude
% * Evaluation of the residual and comparison with theoretical value

close all
clear
clc

%% Setup program execution

% Select the mode of operation
opMode = 'breaking';
opMode = 'continuous';

% Select the airplane Angle-of-Sideslip Sensor and kinematic model
modelArray = {};
modelArray{end+1} = g032a();

% Specify the graph matching method
matchMethod = 'BBILP';

% Specify the desired PSO type
SOType = 'MTES';

% Specify the Brand & Bound ILP branching method
branchMethod = 'DFS';

% Build the options structure
SA_settings.matchMethod = matchMethod;
SA_settings.SOType = SOType;
SA_settings.branchMethod = branchMethod;
SA_settings.plotGraphInitial = true;
SA_settings.plotGraphOver = true;
SA_settings.plotGraphRemaining = true;
SA_settings.plotGraphDisconnected = true;
SA_settings.plotGraphPSO = true;
SA_settings.plotGraphMatched = true;

%% Read the model description and create the initial graph
model = modelArray{1};

%% Perform Structural Analsysis and Matching, extract residual generators
SA_results = structural_analysis(model, SA_settings);

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end

%% Build the residual generators
% Only one has actually been found

RG_settings.dt = 0.1;  % Select the time step: 0.1s corresponds to the log file of a future step

tic
RG_results = get_res_gens(SA_results, RG_settings);
time_generate_residual_generators = toc

% Make a quick printout of the sequential operations needed to evaluate the residual
fprintf('Sequence of calculations for the evaluation of the residual:\n');
for i=1:length(RG_results.res_gen_cell{1}.evaluators_list)
    if ~isempty(RG_results.res_gen_cell{1}.evaluators_list{i}.sym_var_matched_array)
        matchedVar = RG_results.res_gen_cell{1}.evaluators_list{i}.sym_var_matched_array(1);
    else
        matchedVar = '0';
    end
    if ~isempty(RG_results.res_gen_cell{1}.evaluators_list{i}.expressions_solved)
        expression = RG_results.res_gen_cell{1}.evaluators_list{i}.expressions_solved(1);
    else
        expression = '(residual)';
    end
    
    fprintf('%s := %s\n', matchedVar , expression);
end

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end

%% Calculate the Fault Response Vector of each residual generator

fault_response_vector_set = getFaultResponseVector( RG_results.res_gen_cell, [], [] ); % Run all tests, with no pre-calculated fault response vector

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end

%% Run again if you want to run more optimization iterations
% Watch how further Particle Swarm Optimization iterations may yield better min/max results. The previous result is fed back to
% compare min/max results

tests_to_run{1} = [1 0 0 0;...
                   0 0 0 0];

fault_response_vector_set = getFaultResponseVector( RG_results.res_gen_cell, fault_response_vector_set, tests_to_run ); % Run all tests, with no pre-calculated fault response vector

if strcmp(opMode,'breaking')
    input('\nPress Enter to proceed to the next step...');
    clc
end

%% Example using actual log data
% Showing expected, simulated and measured residual response to the previously examined residual generator:
% An Angle-of-Sideslip (AoS) sensor fault occurs, as recorded in a DataFlash log of an ArduPlane autopilot

%% Load and curate the log data
load('GraphPool/g032/dataset.mat');

% Align NKF1 and NKF2 to their ends
% NKF1 and NKF2 are outputs of the autopilot's Extended Kalfman Filter
sample_diff = length(dataset.NKF1.Roll)-length(dataset.NKF2.VWN)+1;

% Import the required quantities
Phi = deg2rad(dataset.NKF1.Roll(sample_diff:end));
Theta = deg2rad(dataset.NKF1.Pitch(sample_diff:end));
Psi = deg2rad(dataset.NKF1.Yaw(sample_diff:end));
Va = dataset.ARSP.Airspeed;
Alpha = deg2rad(dataset.CUR2.Volt-45); % The Angle-of-Attack sensor is hard-wired to the autopilot as a voltmeter
Beta = deg2rad(dataset.CUR2.Curr-45); % The Angle-of-Sideslip sensor is hard-wired to the autopilot as a current meter
Vn = dataset.NKF1.VN(sample_diff:end);
Ve = dataset.NKF1.VE(sample_diff:end);
Vd = dataset.NKF1.VD(sample_diff:end);
Vwn = dataset.NKF2.VWN;
Vwe = dataset.NKF2.VWE;
ay = dataset.IMU.AccY;
% az = dataset.IMU.AccZ;
p = dataset.IMU.GyrX;  % in rads/s
r = dataset.IMU.GyrZ;  % in rads/s

%% Post-process data to obtain body-frame wind velocities 
% Calculate rotation matrix for the whole flight
eul = zeros(3,3,length(Phi));
for i=1:length(eul)
    eul(:,:,i) = eul2rotm([Psi(i) Theta(i) Phi(i)]);    
end

% Calculate body-frame wind components
Vw = zeros(3,length(Phi));  % Preallocate the speeds vector
Vwd = zeros(size(Vwn));  % Assume zero vertical wind

% Rotate the wind component
for i=1:length(Vw)
    Vw(:,i) = eul(:,:,i)'*[Vwn(i) Vwe(i) Vwd(i)]';
end

uw = Vw(1,:);
vw = Vw(2,:);
ww = Vw(3,:);

% Calculate body-frame inertial speeds
Vb = zeros(3,length(Phi));  % Preallocate the speeds vector
for i=1:length(Phi)
    Vb(:,i) = eul(:,:,i)'*[Vn(i) Ve(i) Vd(i)]';
end

u = Vb(1,:);
v = Vb(2,:);
w = Vb(3,:);

% Calculate relative airspeed
ur = u-uw;
vr = v-vw;
wr = w-ww;

%% Down-sample and align all data, based on the lowest rate (AoS);
interpolationMethod = 'linear';
extrapolation = 'extrap';

timeVec = dataset.CUR2.TimeS; % Choose the AoS measurement time vector as the baseline
NKF1_time = dataset.NKF1.TimeS(sample_diff:end);
Phi_D = interp1(NKF1_time, Phi, timeVec, interpolationMethod, extrapolation);
Theta_D = interp1(NKF1_time, Theta, timeVec, interpolationMethod, extrapolation);
Psi_D = interp1(NKF1_time, Psi, timeVec, interpolationMethod, extrapolation);
Va_D = interp1(dataset.ARSP.TimeS, dataset.ARSP.Airspeed, timeVec, interpolationMethod, extrapolation);
u_D = interp1(NKF1_time, u, timeVec, interpolationMethod, extrapolation);
w_D = interp1(NKF1_time, w, timeVec, interpolationMethod, extrapolation);
ur_D = interp1(NKF1_time, ur, timeVec, interpolationMethod, extrapolation);
vr_D = interp1(NKF1_time, vr, timeVec, interpolationMethod, extrapolation);
vw_D = interp1(NKF1_time, vw, timeVec, interpolationMethod, extrapolation);
ay_D = interp1(dataset.IMU.TimeS, ay, timeVec, interpolationMethod, extrapolation);
p_D = interp1(dataset.IMU.TimeS, p, timeVec, interpolationMethod, extrapolation);
r_D = interp1(dataset.IMU.TimeS, r, timeVec, interpolationMethod, extrapolation);

datalog.timestamp = timeVec; % Required field, time vector
% The rest of the field names must match the measured variables aliases found in the RG_results.values dictionary
datalog.Beta_m = Beta;
datalog.Va_m = Va_D;
datalog.r_m = r_D;
datalog.p_m = p_D;
datalog.u_m = u_D;
datalog.w_m = w_D;
datalog.Phi_m = Phi_D;
datalog.Theta_m = Theta_D;
datalog.a_m_y = ay_D;
datalog.v_w_m = vw_D;

%% Calculate the residual

% Evaluate the residual generator automatically
RE_results = evaluateResiduals(SA_results, RG_results, datalog);  
res_auto = RE_results.residuals';

% Use the pre-calculated relative airspeed estimate to estimate the unknown AoS sensor fault magnitude
dt = [diff(timeVec)];
diff_Beta = [0; diff(Beta)./dt];
Beta_est = real(asin(vr_D./Va_D));  % Calculate the AoS estimate
diff_Beta_est = [0; diff(Beta_est)./dt];
f1 = Beta-Beta_est;  % Calculate the error between estimated and measured AoS. This is the fault variable
diff_Va = [0; diff(Va_D)./dt];
diff_f1 = [0; diff(f1)./dt];

% Calculate the expected residual as a theoretical function of the fault
res_est = diff_Va.*(sin(Beta) - sin(Beta_est)) + Va_D.*(cos(Beta).*diff_Beta - cos(Beta_est).*diff_Beta_est); 

%% Plot stuff

% Residual plot vs error
figure();
entries = {};
hold on
grid on
plot(timeVec, abs(res_auto),'b');
entries{end+1} = 'Residual';
plot(timeVec, abs(res_est),'g');
entries{end+1} = 'Expected Residual';
plot(timeVec, 100*abs(f1),'r');
xlabel 'time (s)';
entries{end+1} = 'Fault magnitude *100';
title('Residuals and error');
legend(entries);
ylim([0 500]);

% Beta values
figure();
plot(timeVec, Beta);
hold on
grid on
plot(timeVec, Beta_est,'g');
title('\beta (Angle of Sideslip)');
plot(timeVec, f1,'r');
xlabel 'time (s)';
ylabel 'Angle of Sideslip (rad)';
legend({'Measured AoS','Estimated AoS','Error'});

return