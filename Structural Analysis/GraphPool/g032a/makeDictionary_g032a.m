function [ dictionary ] = makeDictionary_g032a(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
dictionary.setValue([], {'m'}, 12.5);
dictionary.setValue([], {'g'}, 9.81);

%Input Initializations
%Measurement Initializations
dictionary.setValue(36, {'Beta_m'}, 0);
dictionary.setValue(41, {'Va_m'}, 0);
dictionary.setValue(45, {'r_m'}, 0);
dictionary.setValue(49, {'p_m'}, 0);
dictionary.setValue(53, {'u_m'}, 0);
dictionary.setValue(57, {'w_m'}, 0);
dictionary.setValue(63, {'Phi_m'}, 0);
dictionary.setValue(70, {'Theta_m'}, 0);
dictionary.setValue(75, {'a_m_y'}, 0);
dictionary.setValue(84, {'v_w_m'}, 0);

%Fault Initializations
dictionary.setValue(33, {'fseq1'}, 0);
dictionary.setValue(39, {'fseq2'}, 0);
dictionary.setValue(61, {'fseq7'}, 0);
dictionary.setValue(68, {'fseq8'}, 0);

%State Initializations
dictionary.setValue(2, {'v'}, 0);

%Input variable limits Initializations
graphInitial.setLimits([], {'fseq1'}, [deg2rad([-60 60])]);
graphInitial.setLimits([], {'fseq2'}, [-5 5]);
graphInitial.setLimits([], {'fseq7'}, [deg2rad([-5 5])]);
graphInitial.setLimits([], {'fseq8'}, [deg2rad([-5 5])]);

%Measured variable limits Initializations
graphInitial.setLimits([], {'Beta_m'}, [deg2rad([-45 45])]);
graphInitial.setLimits([], {'Va_m'}, [20 35]);
graphInitial.setLimits([], {'r_m'}, [-2 2]);
graphInitial.setLimits([], {'p_m'}, [-2 2]);
graphInitial.setLimits([], {'u_m'}, [20 35]);
graphInitial.setLimits([], {'w_m'}, [-5 5]);
graphInitial.setLimits([], {'Phi_m'}, [deg2rad([-60 60])]);
graphInitial.setLimits([], {'Theta_m'}, [deg2rad([-20 20])]);
graphInitial.setLimits([], {'a_m_y'}, [-15 15]);
graphInitial.setLimits([], {'v_w_m'}, [-5 5]);

end