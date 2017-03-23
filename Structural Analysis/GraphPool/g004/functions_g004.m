function fArray = functions_g004()
	% functions_g004 Function evaluations for graph model g004
fArray{1}{1} = Differentiator();
fArray{1}{2} = Integrator();
fArray{2}{1} = Function();
fArray{2}{1}.fh = @f_6_7;
fArray{2}{2} = Function();
fArray{2}{2}.fh = @f_6_2;
fArray{3}{1} = Differentiator();
fArray{3}{2} = Integrator();
fArray{4}{1} = Function();
fArray{4}{1}.fh = @f_14_11;
fArray{4}{2} = Function();
fArray{4}{2}.fh = @f_14_4;
fArray{4}{3} = Function();
fArray{4}{3}.fh = @f_14_7;
fArray{4}{4} = Function();
fArray{4}{4}.fh = @f_14_18;
fArray{5}{1} = Function();
fArray{5}{1}.fh = @f_20_21;
fArray{5}{2} = Function();
fArray{5}{2}.fh = @f_20_4;

m = 5;
k = 5;
c = 3;

function v = f_6_7(x_dot)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: v x_dot
% Evaluate for variable: v

v = x_dot;
end

function x_dot = f_6_2(v)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: v x_dot
% Evaluate for variable: x_dot

x_dot = v;
end

function v_dot = f_14_11(x,v,u)
% Evaluation definition for equation ceq4 with id 14
% Equation structural description: v_dot x v inp u
% Evaluate for variable: v_dot

v_dot = 1/m*(-k*x -c*v + u);
end

function x = f_14_4(v,v_dot,u)
% Evaluation definition for equation ceq4 with id 14
% Equation structural description: v_dot x v inp u
% Evaluate for variable: x

x = -1/k*(m*v_dot + c*v - u);
end

function v = f_14_7(x,v_dot,u)
% Evaluation definition for equation ceq4 with id 14
% Equation structural description: v_dot x v inp u
% Evaluate for variable: v

v = 1/c*(-m*v_dot - k*x + u);
end

function u = f_14_18(x,v,v_dot)
% Evaluation definition for equation ceq4 with id 14
% Equation structural description: v_dot x v inp u
% Evaluate for variable: u

error('This evaluation is not possible');
end

function x_m = f_20_21(x)
% Evaluation definition for equation ceq5 with id 20
% Equation structural description: msr x_m x
% Evaluate for variable: x_m

error('This evaluation is not possible');
end

function x = f_20_4(x_m)
% Evaluation definition for equation ceq5 with id 20
% Equation structural description: msr x_m x
% Evaluate for variable: x

x = x_m;
end

end