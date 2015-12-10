%% Model of a spring-mass system
% E*x[t+1] = A*x[t] + Bu*u[t] + Bf*f[t] + Be*e[t]
% y[t] = C*x[t] + Du*u[t] + Df*f[t] + Dv*v[t]
% e ~ N(0, 0.1^2), v ~ N([0,0]^T,[1^2 0;0 0.5^2])
E = eye(2);
A = [1 1;-1 1];
Bu = [0;1];
Bf = [0 0 0 0;1 1 0 0];
Be = [0; 1];
Lambdae = [0.1];
C = [1 0;1 0];
Du = [0;0];
Df = [0 0 1 0;0 0 0 1];
Dv = diag([1 1]);
Lambdav = [1 0;0 0.5];

%% Create DistinguishabilityAnalysisClass class to compute
%  distinguishability
DAC = DistinguishabilityAnalysisClass(E, A, Bu, Bf, Be, ...
  C, Du, Df, Dv, Lambdae, Lambdav);

%% Computed analysis results in the paper

% Detectability of fault f3 from fault f1 when theta3 = [1 1 1]^T
% and n = 3.
theta3 = [1 1 1].'; % Constant fault time profile with amplitude 1
n = 3; % Window length n = 3
disp('D_(3,1)([1 1 1]^T): ');
% Compute distinguishability
D_31 = DAC.ComputeDistinguishability(3, 1, theta3, n); 
disp(D_31);

% Table 2
theta3 = [1 1 1].';
n = 3;
% Compute distinguishability matrix
D_ij_3 = DAC.ComputeDistinguishabilityMatrix(theta3, n);
disp('D_(i,j)([1 1 1]^T): (n = 3)');
disp(D_ij_3);

% Table 3
theta6 = [1 1 1 1 1 1].';
n = 6;
% Compute distinguishability matrix
D_ij_6 = DAC.ComputeDistinguishabilityMatrix(theta6, n);
disp('D_(i,j)([1 1 1 1 1 1]^T): (n = 6)');
disp(D_ij_6);

% Table 4
theta2 = [1 1].'; 
n = 2; 
% Compute distinguishability matrix
D_ij_2 = DAC.ComputeDistinguishabilityMatrix(theta2, n);
disp('D_(i,j)([1 1]^T): (n = 2)');
disp(D_ij_2);