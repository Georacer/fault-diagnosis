function fArray = functions_g008()
	% functions_g008 Function evaluations for graph model g008
fArray{1}{1} = Function();
fArray{1}{1}.fh = @f_1_2;
fArray{1}{2} = Function();
fArray{1}{2}.fh = @f_1_4;
fArray{1}{3} = Function();
fArray{1}{3}.fh = @f_1_6;
fArray{2}{1} = Function();
fArray{2}{1}.fh = @f_8_9;
fArray{2}{2} = Function();
fArray{2}{2}.fh = @f_8_6;
fArray{2}{3} = Function();
fArray{2}{3}.fh = @f_8_12;
fArray{3}{1} = Function();
fArray{3}{1}.fh = @f_14_15;
fArray{3}{2} = Function();
fArray{3}{2}.fh = @f_14_12;
fArray{4}{1} = Function();
fArray{4}{1}.fh = @f_18_19;
fArray{4}{2} = Function();
fArray{4}{2}.fh = @f_18_21;
fArray{4}{3} = Function();
fArray{4}{3}.fh = @f_18_2;
fArray{5}{1} = Function();
fArray{5}{1}.fh = @f_24_25;
fArray{5}{2} = Function();
fArray{5}{2}.fh = @f_24_2;
fArray{5}{3} = Function();
fArray{5}{3}.fh = @f_24_9;
fArray{6}{1} = Function();
fArray{6}{1}.fh = @f_29_30;
fArray{6}{2} = Function();
fArray{6}{2}.fh = @f_29_9;
fArray{6}{3} = Function();
fArray{6}{3}.fh = @f_29_15;
fArray{7}{1} = Integrator();
fArray{7}{2} = Differentiator();
fArray{8}{1} = Integrator();
fArray{8}{2} = Differentiator();
fArray{9}{1} = Integrator();
fArray{9}{2} = Differentiator();
fArray{10}{1} = Function();
fArray{10}{1}.fh = @f_43_44;
fArray{10}{2} = Function();
fArray{10}{2}.fh = @f_43_4;
fArray{11}{1} = Function();
fArray{11}{1}.fh = @f_47_48;
fArray{11}{2} = Function();
fArray{11}{2}.fh = @f_47_9;
fArray{12}{1} = Function();
fArray{12}{1}.fh = @f_51_52;
fArray{12}{2} = Function();
fArray{12}{2}.fh = @f_51_21;

Rv1 = 1;
Rv2 = 1;
Rv3 = 1;
C1 = 1;
C2 = 1;
C3 = 1;


function q1 = f_1_2(p1,p2)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: q1 p1 p2
% Evaluate for variable: q1

q1 = 1/Rv1*(p1 - p2);
end

function p1 = f_1_4(q1,p2)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: q1 p1 p2
% Evaluate for variable: p1

p1 = q1*Rv1 + p2;
end

function p2 = f_1_6(q1,p1)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: q1 p1 p2
% Evaluate for variable: p2

p2 = p1 - q1*Rv1;
end

function q2 = f_8_9(p2,p3)
% Evaluation definition for equation ceq2 with id 8
% Equation structural description: q2 p2 p3
% Evaluate for variable: q2

q2 = 1/Rv2*(p2 - p3);
end

function p2 = f_8_6(q2,p3)
% Evaluation definition for equation ceq2 with id 8
% Equation structural description: q2 p2 p3
% Evaluate for variable: p2

p2 = q2*Rv2 + p3;
end

function p3 = f_8_12(p2,q2)
% Evaluation definition for equation ceq2 with id 8
% Equation structural description: q2 p2 p3
% Evaluate for variable: p3

p3 = p2 - q2*Rv2;
end

function q3 = f_14_15(p3)
% Evaluation definition for equation ceq3 with id 14
% Equation structural description: q3 p3
% Evaluate for variable: q3

q3 = 1/Rv3*p3;
end

function p3 = f_14_12(q3)
% Evaluation definition for equation ceq3 with id 14
% Equation structural description: q3 p3
% Evaluate for variable: p3

p3 = q3*Rv3;
end

function p1_dot = f_18_19(q1,q0)
% Evaluation definition for equation ceq4 with id 18
% Equation structural description: p1_dot q0 q1
% Evaluate for variable: p1_dot

p1_dot = 1/C1*(q0-q1);
end

function q0 = f_18_21(q1,p1_dot)
% Evaluation definition for equation ceq4 with id 18
% Equation structural description: p1_dot q0 q1
% Evaluate for variable: q0

q0 = p1_dot * C1 + q1;
end

function q1 = f_18_2(p1_dot,q0)
% Evaluation definition for equation ceq4 with id 18
% Equation structural description: p1_dot q0 q1
% Evaluate for variable: q1

q1 = q0 + p1_dot * C1;
end

function p2_dot = f_24_25(q1,q2)
% Evaluation definition for equation ceq5 with id 24
% Equation structural description: p2_dot q1 q2
% Evaluate for variable: p2_dot

p2_dot = 1/C2*(q1-q2);
end

function q1 = f_24_2(q2,p2_dot)
% Evaluation definition for equation ceq5 with id 24
% Equation structural description: p2_dot q1 q2
% Evaluate for variable: q1

q1 = p2_dot * C2 + q2;
end

function q2 = f_24_9(q1,p2_dot)
% Evaluation definition for equation ceq5 with id 24
% Equation structural description: p2_dot q1 q2
% Evaluate for variable: q2

q2 = q1 + p2_dot * C2;
end

function p3_dot = f_29_30(q2,q3)
% Evaluation definition for equation ceq6 with id 29
% Equation structural description: p3_dot q2 q3
% Evaluate for variable: p3_dot

p3_dot = 1/C3*(q2-q3);
end

function q2 = f_29_9(q3,p3_dot)
% Evaluation definition for equation ceq6 with id 29
% Equation structural description: p3_dot q2 q3
% Evaluate for variable: q2

q2 = p3_dot * C3 + q3;
end

function q3 = f_29_15(q2,p3_dot)
% Evaluation definition for equation ceq6 with id 29
% Equation structural description: p3_dot q2 q3
% Evaluate for variable: q3

q3 = q2 + p3_dot * C3;
end

function y1 = f_43_44(p1)
% Evaluation definition for equation seq1 with id 43
% Equation structural description: msr y1 p1
% Evaluate for variable: y1

error('This evaluation is not possible');
end

function p1 = f_43_4(y1)
% Evaluation definition for equation seq1 with id 43
% Equation structural description: msr y1 p1
% Evaluate for variable: p1

p1 = y1;
end

function y2 = f_47_48(q2)
% Evaluation definition for equation seq2 with id 47
% Equation structural description: msr y2 q2
% Evaluate for variable: y2

error('This evaluation is not possible');
end

function q2 = f_47_9(y2)
% Evaluation definition for equation seq2 with id 47
% Equation structural description: msr y2 q2
% Evaluate for variable: q2

q2 = y2;
end

function y3 = f_51_52(q0)
% Evaluation definition for equation seq3 with id 51
% Equation structural description: msr y3 q0
% Evaluate for variable: y3

error('This evaluation is not possible');
end

function q0 = f_51_21(y3)
% Evaluation definition for equation seq3 with id 51
% Equation structural description: msr y3 q0
% Evaluate for variable: q0

q0 = y3;
end

end