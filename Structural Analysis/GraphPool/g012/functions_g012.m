function fArray = functions_g012()
	% functions_g012 Function evaluations for graph model g012
fArray{1}{1} = Function();
fArray{1}{1}.fh = @f_1_2;
fArray{1}{2} = Function();
fArray{1}{2}.fh = @f_1_4;
fArray{1}{3} = Function();
fArray{1}{3}.fh = @f_1_6;
fArray{1}{4} = Function();
fArray{1}{4}.fh = @f_1_8;
fArray{1}{5} = Function();
fArray{1}{5}.fh = @f_1_10;
fArray{1}{6} = Function();
fArray{1}{6}.fh = @f_1_12;
fArray{1}{7} = Function();
fArray{1}{7}.fh = @f_1_14;
fArray{2}{1} = Function();
fArray{2}{1}.fh = @f_16_17;
fArray{2}{2} = Function();
fArray{2}{2}.fh = @f_16_4;
fArray{2}{3} = Function();
fArray{2}{3}.fh = @f_16_6;
fArray{2}{4} = Function();
fArray{2}{4}.fh = @f_16_8;
fArray{2}{5} = Function();
fArray{2}{5}.fh = @f_16_12;
fArray{2}{6} = Function();
fArray{2}{6}.fh = @f_16_14;
fArray{3}{1} = Function();
fArray{3}{1}.fh = @f_24_25;
fArray{3}{2} = Function();
fArray{3}{2}.fh = @f_24_4;
fArray{3}{3} = Function();
fArray{3}{3}.fh = @f_24_6;
fArray{3}{4} = Function();
fArray{3}{4}.fh = @f_24_8;
fArray{3}{5} = Function();
fArray{3}{5}.fh = @f_24_12;
fArray{3}{6} = Function();
fArray{3}{6}.fh = @f_24_14;
fArray{4}{1} = Function();
fArray{4}{1}.fh = @f_32_33;
fArray{4}{2} = Function();
fArray{4}{2}.fh = @f_32_6;
fArray{5}{1} = Differentiator();
fArray{5}{2} = Integrator();
fArray{6}{1} = Differentiator();
fArray{6}{2} = Integrator();
fArray{7}{1} = Differentiator();
fArray{7}{2} = Integrator();
fArray{8}{1} = Differentiator();
fArray{8}{2} = Integrator();
fArray{9}{1} = Function();
fArray{9}{1}.fh = @f_48_49;
fArray{9}{2} = Function();
fArray{9}{2}.fh = @f_48_6;
fArray{10}{1} = Function();
fArray{10}{1}.fh = @f_52_53;
fArray{10}{2} = Function();
fArray{10}{2}.fh = @f_52_8;

Alat = [...
   -0.5063    4.4206  -19.5053    7.9726         0;...
   -2.5461   -9.2390    4.0152         0         0;...
    2.6963   -0.2991   -5.5561         0         0;...
         0    1.0000    0.1553   -0.0000         0;...
         0         0    0.8422    0.0000         0;...
         ];

Blat = [...
         0   -1.7567;...
   41.6271   50.8836;...
   16.6279   -3.8657;...
         0         0;...
         0         0;...
         ];


function b_dot = f_1_2(b,p,r,phi,deltaa,deltar)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: b_dot

b_dot = Alat(1,:)*[b p r phi]' + Blat(1,:)*[deltaa deltar]';
end

function b = f_1_4(b_dot,p,r,phi,deltaa,deltar)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: b

b = 1/Alat(1,1)*(b_dot - Alat(1,2:4)*[p r phi]' + Blat(1,:)*[deltaa deltar]');
end

function p = f_1_6(b_dot,b,r,phi,deltaa,deltar)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: p

p = 1/Alat(1,2)*(b_dot - Alat(1,[1 3 4])*[b r phi]' + Blat(1,:)*[deltaa deltar]');
end

function r = f_1_8(b_dot,b,p,phi,deltaa,deltar)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: r

r = 1/Alat(1,3)*(b_dot - Alat(1,[1 2 4])*[b p phi]' + Blat(1,:)*[deltaa deltar]');
end

function phi = f_1_10(b_dot,b,p,r,deltaa,deltar)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: phi

phi = 1/Alat(1,4)*(b_dot - Alat(1,1:3)*[b p r]' + Blat(1,:)*[deltaa deltar]');
end

function deltaa = f_1_12(b_dot,b,p,r,phi,deltar)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: deltaa

error('This evaluation is not possible');
end

function deltar = f_1_14(b_dot,b,p,r,phi,deltaa)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: fault b_dot b p r phi inp deltaa inp deltar
% Evaluate for variable: deltar

error('This evaluation is not possible');
end

function p_dot = f_16_17(b,p,r,deltaa,deltar)
% Evaluation definition for equation ceq2 with id 16
% Equation structural description: fault p_dot b p r inp deltaa inp deltar
% Evaluate for variable: p_dot

p_dot = Alat(2,1:3)*[b p r]' + Blat(2,:)*[deltaa deltar]';
end

function b = f_16_4(p,r,deltaa,deltar,p_dot)
% Evaluation definition for equation ceq2 with id 16
% Equation structural description: fault p_dot b p r inp deltaa inp deltar
% Evaluate for variable: b

b = 1/Alat(2,1)*(p_dot - Alat(2,2:3)*[p r]' + Blat(2,:)*[deltaa deltar]');
end

function p = f_16_6(b,r,deltaa,deltar,p_dot)
% Evaluation definition for equation ceq2 with id 16
% Equation structural description: fault p_dot b p r inp deltaa inp deltar
% Evaluate for variable: p

p = 1/Alat(2,2)*(p_dot - Alat(2,[1 3])*[b r]' + Blat(2,:)*[deltaa deltar]');
end

function r = f_16_8(b,p,deltaa,deltar,p_dot)
% Evaluation definition for equation ceq2 with id 16
% Equation structural description: fault p_dot b p r inp deltaa inp deltar
% Evaluate for variable: r

r = 1/Alat(2,3)*(p_dot - Alat(2,1:2)*[b p]' + Blat(2,:)*[deltaa deltar]');
end

function deltaa = f_16_12(b,p,r,deltar,p_dot)
% Evaluation definition for equation ceq2 with id 16
% Equation structural description: fault p_dot b p r inp deltaa inp deltar
% Evaluate for variable: deltaa

error('This evaluation is not possible');
end

function deltar = f_16_14(b,p,r,deltaa,p_dot)
% Evaluation definition for equation ceq2 with id 16
% Equation structural description: fault p_dot b p r inp deltaa inp deltar
% Evaluate for variable: deltar

error('This evaluation is not possible');
end

function r_dot = f_24_25(b,p,r,deltaa,deltar)
% Evaluation definition for equation ceq3 with id 24
% Equation structural description: fault r_dot b p r inp deltaa inp deltar
% Evaluate for variable: r_dot

r_dot = Alat(3,1:3)*[b p r]' + Blat(3,:)*[deltaa deltar]';
end

function b = f_24_4(p,r,deltaa,deltar,r_dot)
% Evaluation definition for equation ceq3 with id 24
% Equation structural description: fault r_dot b p r inp deltaa inp deltar
% Evaluate for variable: b

b = 1/Alat(3,1)*(r_dot - Alat(3,2:3)*[p r]' + Blat(3,:)*[deltaa deltar]');
end

function p = f_24_6(b,r,deltaa,deltar,r_dot)
% Evaluation definition for equation ceq3 with id 24
% Equation structural description: fault r_dot b p r inp deltaa inp deltar
% Evaluate for variable: p

p = 1/Alat(3,2)*(r_dot - Alat(3,[1 3])*[b r]' + Blat(3,:)*[deltaa deltar]');
end

function r = f_24_8(b,p,deltaa,deltar,r_dot)
% Evaluation definition for equation ceq3 with id 24
% Equation structural description: fault r_dot b p r inp deltaa inp deltar
% Evaluate for variable: r

r = 1/Alat(3,3)*(r_dot - Alat(3,1:2)*[b p]' + Blat(3,:)*[deltaa deltar]');
end

function deltaa = f_24_12(b,p,r,deltar,r_dot)
% Evaluation definition for equation ceq3 with id 24
% Equation structural description: fault r_dot b p r inp deltaa inp deltar
% Evaluate for variable: deltaa

error('This evaluation is not possible');
end

function deltar = f_24_14(b,p,r,deltaa,r_dot)
% Evaluation definition for equation ceq3 with id 24
% Equation structural description: fault r_dot b p r inp deltaa inp deltar
% Evaluate for variable: deltar

error('This evaluation is not possible');
end

function phi_dot = f_32_33(p)
% Evaluation definition for equation ceq4 with id 32
% Equation structural description: phi_dot p
% Evaluate for variable: phi_dot

phi_dot = p;
end

function p = f_32_6(phi_dot)
% Evaluation definition for equation ceq4 with id 32
% Equation structural description: phi_dot p
% Evaluate for variable: p

p = phi_dot;
end

function y1 = f_48_49(p)
% Evaluation definition for equation seq1 with id 48
% Equation structural description: fault msr y1 p
% Evaluate for variable: y1

error('This evaluation is not possible');
end

function p = f_48_6(y1)
% Evaluation definition for equation seq1 with id 48
% Equation structural description: fault msr y1 p
% Evaluate for variable: p

p = y1;
end

function y2 = f_52_53(r)
% Evaluation definition for equation seq2 with id 52
% Equation structural description: fault msr y2 r
% Evaluate for variable: y2

error('This evaluation is not possible');
end

function r = f_52_8(y2)
% Evaluation definition for equation seq2 with id 52
% Equation structural description: fault msr y2 r
% Evaluate for variable: r

r = y2;
end

end