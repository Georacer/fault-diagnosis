function [ dictionary ] = makeDictionary_g024a(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

R_s = 0.0697;
L_s = 0.00011;
L_r = 0.00011;
P = 2;
R_r = 0.3471;
L_M = 0.00266;
J = 0.00294;
sigma = (L_r*L_s-L_M^2);
k = 1/J;
c_t = P*L_M/L_r;
a = (L_r^2*R_s+L_M^2*R_r)/sigma*L_r;
b = L_M/sigma;
c = R_r/L_r;
d = L_r/sigma;
c_f = 0.547;

%Parameter Initializations
dictionary.setValue([], {'a'}, a);
dictionary.setValue([], {'b'}, b);
dictionary.setValue([], {'c'}, c);
dictionary.setValue([], {'d'}, d);
dictionary.setValue([], {'L_M'}, L_M);
dictionary.setValue([], {'k'}, k);
dictionary.setValue([], {'c_f'}, c_f);
dictionary.setValue([], {'c_t'}, c_t);

%Input Initializations
dictionary.setValue(12, {'u_a'}, 0);
dictionary.setValue(31, {'u_b'}, 0);
dictionary.setValue(65, {'Tl'}, 0);

%Measurement Initializations
dictionary.setValue(91, {'i_a_m'}, 1);
dictionary.setValue(97, {'i_b_m'}, 1);
dictionary.setValue(103, {'w_m'}, 1);

%Fault Initializations
dictionary.setValue(89, {'fseq1'}, 0);
dictionary.setValue(95, {'fseq2'}, 0);
dictionary.setValue(101, {'fseq3'}, 0);

%State Initializations
dictionary.setValue(4, {'i_a'}, 1);
dictionary.setValue(6, {'lambda_a'}, 0);
dictionary.setValue(8, {'lambda_b'}, 0);
dictionary.setValue(25, {'i_b'}, 1);
dictionary.setValue(43, {'w'}, 238);

%Input variable limits Initializations
graphInitial.setLimits([], {'u_a'}, [-1 1]);
graphInitial.setLimits([], {'u_b'}, [-1 1]);
graphInitial.setLimits([], {'Tl'}, [-1 1]);
graphInitial.setLimits([], {'fseq1'}, [-1 1]);
graphInitial.setLimits([], {'fseq2'}, [-1 1]);
graphInitial.setLimits([], {'fseq3'}, [-1 1]);

%Measured variable limits Initializations
graphInitial.setLimits([], {'i_a_m'}, [-1 1]);
graphInitial.setLimits([], {'i_b_m'}, [-1 1]);
graphInitial.setLimits([], {'w_m'}, [100 300]);

end