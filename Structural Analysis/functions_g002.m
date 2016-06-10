function fArray = functions_g002()
	% functions_g002 Function evaluations for graph model g002
fArray{1}{1} = @f_1_2;
fArray{1}{2} = @f_1_4;
fArray{2}{1} = @f_6_4;
fArray{2}{2} = @f_6_8;
fArray{2}{3} = @f_6_10;
fArray{3}{1} = @f_12_8;
fArray{3}{2} = @f_12_14;
fArray{4}{1} = @f_16_10;
fArray{4}{2} = @f_16_18;
fArray{5}{1} = @f_20_18;
fArray{5}{2} = @f_20_22;

function da_c = f_1_2(da)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: msr da_c da
% Evaluate for variable: da_c

error('This evaluation is not possible');
end

function da = f_1_4(da_c)
% Evaluation definition for equation ceq1 with id 1
% Equation structural description: msr da_c da
% Evaluate for variable: da

da = da_c;
end

function da = f_6_4(Va,l)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: da Va l
% Evaluate for variable: da

% Write calculation here
end

function Va = f_6_8(da,l)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: da Va l
% Evaluate for variable: Va

% Write calculation here
end

function l = f_6_10(da,Va)
% Evaluation definition for equation ceq2 with id 6
% Equation structural description: da Va l
% Evaluate for variable: l

% Write calculation here
end

function Va = f_12_8(Va_m)
% Evaluation definition for equation ceq3 with id 12
% Equation structural description: Va msr Va_m
% Evaluate for variable: Va

% Write calculation here
end

function Va_m = f_12_14(Va)
% Evaluation definition for equation ceq3 with id 12
% Equation structural description: Va msr Va_m
% Evaluate for variable: Va_m

error('This evaluation is not possible');
end

function l = f_16_10(p)
% Evaluation definition for equation ceq4 with id 16
% Equation structural description: l p
% Evaluate for variable: l

% Write calculation here
end

function p = f_16_18(l)
% Evaluation definition for equation ceq4 with id 16
% Equation structural description: l p
% Evaluate for variable: p

% Write calculation here
end

function p = f_20_18(p_m)
% Evaluation definition for equation ceq5 with id 20
% Equation structural description: p msr p_m
% Evaluate for variable: p

% Write calculation here
end

function p_m = f_20_22(p)
% Evaluation definition for equation ceq5 with id 20
% Equation structural description: p msr p_m
% Evaluate for variable: p_m

error('This evaluation is not possible');
end

end