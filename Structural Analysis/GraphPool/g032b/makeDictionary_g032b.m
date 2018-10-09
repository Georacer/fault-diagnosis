function [ dictionary ] = makeDictionary_g032b(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
dictionary.setValue([], {'m'}, 12.5);
dictionary.setValue([], {'g'}, 9.81);

%Input Initializations
%Measurement Initializations
dictionary.setValue([], {'Beta_m'}, 0);
dictionary.setValue([], {'Va_m'}, 0);
dictionary.setValue([], {'r_m'}, 0);
dictionary.setValue([], {'p_m'}, 0);
dictionary.setValue([], {'u_m'}, 0);
dictionary.setValue([], {'w_m'}, 0);
dictionary.setValue([], {'Phi_m'}, 0);
dictionary.setValue([], {'Theta_m'}, 0);
dictionary.setValue([], {'a_m_y'}, 0);
dictionary.setValue([], {'v_w_m'}, 0);

%Fault Initializations
dictionary.setValue([], {'fseq1'}, 0);
dictionary.setValue([], {'fseq2'}, 0);
dictionary.setValue([], {'fseq7'}, 0);
dictionary.setValue([], {'fseq8'}, 0);

%Disturbances Initializations
dictionary.setValue([], {'d_Va'}, 0);
dictionary.setValue([], {'d_u'}, 0);
dictionary.setValue([], {'d_w'}, 0);
dictionary.setValue([], {'d_Phi'}, 0);
dictionary.setValue([], {'d_Theta'}, 0);
dictionary.setValue([], {'d_ay'}, 0);
dictionary.setValue([], {'d_g'}, 0);
dictionary.setValue([], {'d_r'}, 0);
dictionary.setValue([], {'d_p'}, 0);

%State Initializations
dictionary.setValue([], {'v'}, 0);

%Input variable limits Initializations
graphInitial.setLimits([], {'fseq1'}, [deg2rad([-90 90])]);
graphInitial.setLimits([], {'fseq2'}, [-5 5]);
graphInitial.setLimits([], {'fseq7'}, [deg2rad([-5 5])]);
graphInitial.setLimits([], {'fseq8'}, [deg2rad([-5 5])]);
graphInitial.setLimits([], {'d_Va'}, [-2 2]);
graphInitial.setLimits([], {'d_Beta'}, [deg2rad([-1.5 1.5])]);
graphInitial.setLimits([], {'d_u'}, [-2 2]);
graphInitial.setLimits([], {'d_w'}, [-1 1]);
graphInitial.setLimits([], {'d_Phi'}, [-deg2rad(2) deg2rad(2)]);
graphInitial.setLimits([], {'d_Theta'}, [-deg2rad(0.2) deg2rad(0.2)]);
graphInitial.setLimits([], {'d_ay'}, [-2 2]);
graphInitial.setLimits([], {'d_g'}, [-0.05 0.05]);
graphInitial.setLimits([], {'d_r'}, [-0.15 0.15]);
graphInitial.setLimits([], {'d_p'}, [-0.2 0.2]);

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
graphInitial.setLimits([], {'v_w_m'}, [-2 2]);

end