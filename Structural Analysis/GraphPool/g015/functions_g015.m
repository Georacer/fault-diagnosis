function fArray = functions_g015()
	% functions_g015 Function evaluations for graph model g015
fArray{1}{1} = Function();
fArray{1}{1}.fh = @f_1_2;
fArray{1}{2} = Function();
fArray{1}{2}.fh = @f_1_4;
fArray{2}{1} = Function();
fArray{2}{1}.fh = @f_6_7;
fArray{2}{2} = Function();
fArray{2}{2}.fh = @f_6_4;
fArray{3}{1} = Function();
fArray{3}{1}.fh = @f_10_11;
fArray{3}{2} = Function();
fArray{3}{2}.fh = @f_10_7;
fArray{4}{1} = Function();
fArray{4}{1}.fh = @f_14_15;
fArray{4}{2} = Function();
fArray{4}{2}.fh = @f_14_11;

function theta_c = f_1_2(theta)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: inp theta_c theta
% Evaluate for variable: theta_c

error('This evaluation is not possible');
end

function theta = f_1_4(theta_c)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: inp theta_c theta
% Evaluate for variable: theta

theta = theta_c;
end

function h = f_6_7(theta)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: h theta
% Evaluate for variable: h
R = 5;
h = theta * R;
end

function theta = f_6_4(h)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: h theta
% Evaluate for variable: theta
R = 5;
theta = h/R;
end

function F = f_10_11(h)
% Evaluation definition for equation ceq3 with id 10
% Equation structural description: F h
% Evaluate for variable: F
k = 3;
F = -k*h;
end

function h = f_10_7(F)
% Evaluation definition for equation ceq3 with id 10
% Equation structural description: F h
% Evaluate for variable: h

k = 3;
h = -F/k;
end

function F_m = f_14_15(F)
% Evaluation definition for equation ceq4 with id 14
% Equation structural description: msr F_m F
% Evaluate for variable: F_m

error('This evaluation is not possible');
end

function F = f_14_11(F_m)
% Evaluation definition for equation ceq4 with id 14
% Equation structural description: msr F_m F
% Evaluate for variable: F

F = F_m;
end

end