% d = pso_opt.res_gen.values;
% a_m_y = d.getValue([],{'a_m_y'});
% Phi = d.getValue([],{'Phi'});
% Theta = d.getValue([],{'Theta'});

g = 9.81;
m = 12.5;
v0 = 0;
dt = 0.01;

% PSO values
% Beta_m = 0.010696;
%  Va_m = 25.000000;
%   r_m = 1.715600;
%   p_m = 1.742408;
%   u_m = 13.690914;
%   w_m = -1.858525;
% Phi_m = 3.002829;
% Theta_m = 1.276567;
% a_m_y = 6.097643;
% fseq1 = -1.578837;
% % fseq1 = 0;

% Sympy values
Beta_m = -0.7854;
 Va_m = 25.000000;
  r_m = 1.715600;
  p_m = 1.742408;
  u_m = 13.690914;
  w_m = -1.858525;
Phi_m = 3.002829;
Theta_m = 1.276567;
a_m_y = 100*Va_m*sin(Beta_m)-p_m*w_m-r_m*u_m-100*v0+9.81*sin(Phi_m)*cos(Theta_m);
% fseq1 = 2.35619;
fseq1 = 0;

w = w_m;
u = u_m;
r = r_m;
p = p_m;
Va = Va_m;
% Va = Va_m+fseq2;
% Beta = Beta_m;
Beta = Beta_m+fseq1;
Theta = Theta_m;
Phi = Phi_m;

results = cell(5,2);

results{1,1} = 'a_m_y';
results{1,2} = a_m_y;

Fy = (a_m_y+sin(Phi)*cos(Theta)*g)*m;
results{2,1} = 'Fy';
results{2,2} = Fy;

dot_v = r*u+p*w+Fy/m;
results{3,1} = 'dot_v';
results{3,2} = dot_v;

v = sin(Beta)*Va;
results{4,1} = 'v';
results{4,2} = v;

res = (v-v0)/dt - dot_v;
results{5,1} = 'res';
results{5,2} = res;

disp(results);
