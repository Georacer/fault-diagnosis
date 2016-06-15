function fArray = functions_g003()
	% functions_g003 Function evaluations for graph model g003
fArray{1}{1} = Function();
fArray{1}{1}.fh = @f_1_2;
fArray{1}{2} = Function();
fArray{1}{2}.fh = @f_1_4;
fArray{1}{3} = Function();
fArray{1}{3}.fh = @f_1_6;
fArray{2}{1} = Function();
fArray{2}{1}.fh = @f_8_2;
fArray{2}{2} = Function();
fArray{2}{2}.fh = @f_8_4;
fArray{2}{3} = Function();
fArray{2}{3}.fh = @f_8_11;
fArray{3}{1} = Differentiator();
fArray{3}{2} = Integrator();
fArray{4}{1} = Function();
fArray{4}{1}.fh = @f_17_15;
fArray{4}{2} = Function();
fArray{4}{2}.fh = @f_17_19;
fArray{5}{1} = Function();
fArray{5}{1}.fh = @f_21_6;
fArray{5}{2} = Function();
fArray{5}{2}.fh = @f_21_23;
fArray{6}{1} = Function();
fArray{6}{1}.fh = @f_25_15;
fArray{6}{2} = Function();
fArray{6}{2}.fh = @f_25_27;
fArray{7}{1} = Function();
fArray{7}{1}.fh = @f_29_2;
fArray{7}{2} = Function();
fArray{7}{2}.fh = @f_29_31;
fArray{8}{1} = Function();
fArray{8}{1}.fh = @f_33_34;
fArray{8}{2} = Function();
fArray{8}{2}.fh = @f_33_4;

function V_a = f_1_2(theta,V_g)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: V_a ni theta V_g
% Evaluate for variable: V_a

V_a = V_g / cos(theta);
end

function theta = f_1_4(V_a,V_g)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: V_a ni theta V_g
% Evaluate for variable: theta

theta = acos(V_g/V_a);
end

function V_g = f_1_6(V_a,theta)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: V_a ni theta V_g
% Evaluate for variable: V_g

V_g = V_a * cos(theta);
end

function V_a = f_8_2(theta,h_dot)
% Evaluation definition for equation ceq2 with id 8
% Equation structural description: V_a ni theta h_dot
% Evaluate for variable: V_a

V_a = h_dot / cos(theta);
end

function theta = f_8_4(V_a,h_dot)
% Evaluation definition for equation ceq2 with id 8
% Equation structural description: V_a ni theta h_dot
% Evaluate for variable: theta

theta = acos(h_dot/V_a);
end

function h_dot = f_8_11(V_a,theta)
% Evaluation definition for equation ceq2 with id 8
% Equation structural description: V_a ni theta h_dot
% Evaluate for variable: h_dot

h_dot = V_a * cos(theta);
end

function h = f_17_15(h_gps)
% Evaluation definition for equation ceq4 with id 17
% Equation structural description: h msr h_gps
% Evaluate for variable: h

h = h_gps;
end

function h_gps = f_17_19(h)
% Evaluation definition for equation ceq4 with id 17
% Equation structural description: h msr h_gps
% Evaluate for variable: h_gps

error('This evaluation is not possible');
end

function V_g = f_21_6(V_g_gps)
% Evaluation definition for equation ceq5 with id 21
% Equation structural description: V_g msr V_g_gps
% Evaluate for variable: V_g

V_g = V_g_gps;
end

function V_g_gps = f_21_23(V_g)
% Evaluation definition for equation ceq5 with id 21
% Equation structural description: V_g msr V_g_gps
% Evaluate for variable: V_g_gps

error('This evaluation is not possible');
end

function h = f_25_15(h_bar)
% Evaluation definition for equation ceq6 with id 25
% Equation structural description: h msr h_bar
% Evaluate for variable: h

h = h_bar;
end

function h_bar = f_25_27(h)
% Evaluation definition for equation ceq6 with id 25
% Equation structural description: h msr h_bar
% Evaluate for variable: h_bar

error('This evaluation is not possible');
end

function V_a = f_29_2(V_a_m)
% Evaluation definition for equation ceq7 with id 29
% Equation structural description: V_a msr V_a_m
% Evaluate for variable: V_a

V_a = V_a_m;
end

function V_a_m = f_29_31(V_a)
% Evaluation definition for equation ceq7 with id 29
% Equation structural description: V_a msr V_a_m
% Evaluate for variable: V_a_m

error('This evaluation is not possible');
end

function theta_m = f_33_34(theta)
% Evaluation definition for equation ceq8 with id 33
% Equation structural description: msr theta_m theta
% Evaluate for variable: theta_m

error('This evaluation is not possible');
end

function theta = f_33_4(theta_m)
% Evaluation definition for equation ceq8 with id 33
% Equation structural description: msr theta_m theta
% Evaluate for variable: theta

theta = theta_m;
end

end