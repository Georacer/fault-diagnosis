function [ dictionary ] = makeDictionary_g005a(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
dictionary.setValue([], {'m'}, 20.63);
dictionary.setValue([], {'Pl'}, 0.62);
dictionary.setValue([], {'Pn'}, -0.02);
dictionary.setValue([], {'Ppq'}, -0.02);
dictionary.setValue([], {'Pqr'}, 0.19);
dictionary.setValue([], {'Qm'}, 0.13);
dictionary.setValue([], {'Qpp'}, 0.03);
dictionary.setValue([], {'Qpr'}, 0.74);
dictionary.setValue([], {'Qrr'}, -0.03);
dictionary.setValue([], {'Rl'}, -0.02);
dictionary.setValue([], {'Rn'}, 0.13);
dictionary.setValue([], {'Rpq'}, -0.82);
dictionary.setValue([], {'Rqr'}, 0.02);
dictionary.setValue([], {'CX0'}, 0.0068);
dictionary.setValue([], {'CXa'}, 0.43);
dictionary.setValue([], {'CXde'}, -0.24);
dictionary.setValue([], {'S'}, 1.36);
dictionary.setValue([], {'CY0'}, 0.020);
dictionary.setValue([], {'CYb'}, 0.3);
dictionary.setValue([], {'CYp'}, 0.83);
dictionary.setValue([], {'CYr'}, -1.077);
dictionary.setValue([], {'CYda'}, 0.21);
dictionary.setValue([], {'CYdr'}, -0.44);
dictionary.setValue([], {'bw'}, 1.96);
dictionary.setValue([], {'CZ0'}, 0.0038);
dictionary.setValue([], {'CZa'}, 2.45);
dictionary.setValue([], {'CZq'}, 0.035);
dictionary.setValue([], {'CZde'}, -0.32);
dictionary.setValue([], {'c'}, 0.76);
dictionary.setValue([], {'Cl0'}, -0.0015);
dictionary.setValue([], {'Clb'}, -0.045);
dictionary.setValue([], {'Clp'}, -0.22);
dictionary.setValue([], {'Clr'}, 0.09);
dictionary.setValue([], {'Clda'}, -0.05);
dictionary.setValue([], {'Cldr'}, 0.01);
dictionary.setValue([], {'Cm0'}, 0.0063);
dictionary.setValue([], {'Cma'}, -0.23);
dictionary.setValue([], {'Cmq'}, -2.69);
dictionary.setValue([], {'Cmde'}, -0.26);
dictionary.setValue([], {'Cn0'}, 0.00013);
dictionary.setValue([], {'Cnb'}, 0.054);
dictionary.setValue([], {'Cnp'}, -0.11);
dictionary.setValue([], {'Cnr'}, -0.26);
dictionary.setValue([], {'Cnda'}, -0.02);
dictionary.setValue([], {'Cndr'}, -0.06);
dictionary.setValue([], {'g'}, 9.80);

%Input Initializations
dictionary.setValue(350, {'Xt_c'}, 0);
dictionary.setValue(356, {'da_c'}, 0);
dictionary.setValue(362, {'de_c'}, 0);
dictionary.setValue(368, {'dr_c'}, 0);

%Measurement Initializations
dictionary.setValue(374, {'V_m'}, 0);
dictionary.setValue(380, {'a_m'}, 0);
dictionary.setValue(386, {'b_m'}, 0);
dictionary.setValue(390, {'p_m'}, 0);
dictionary.setValue(394, {'q_m'}, 0);
dictionary.setValue(398, {'r_m'}, 0);
dictionary.setValue(402, {'Psi_m'}, 0);
dictionary.setValue(406, {'Theta_m'}, 0);
dictionary.setValue(410, {'Phi_m'}, 0);
dictionary.setValue(416, {'h_m'}, 0);
dictionary.setValue(422, {'qbar_m'}, 0);

%Fault Initializations
dictionary.setValue(347, {'fseq1'}, 0);
dictionary.setValue(353, {'fseq2'}, 0);
dictionary.setValue(359, {'fseq3'}, 0);
dictionary.setValue(365, {'fseq4'}, 0);
dictionary.setValue(371, {'fseq5'}, 0);
dictionary.setValue(377, {'fseq6'}, 0);
dictionary.setValue(383, {'fseq7'}, 0);
dictionary.setValue(413, {'fseq14'}, 0);
dictionary.setValue(419, {'fseq15'}, 0);

%State Initializations
dictionary.setValue(4, {'a'}, 0);
dictionary.setValue(6, {'b'}, 0);
dictionary.setValue(21, {'V'}, 15);
dictionary.setValue(23, {'q'}, 0);
dictionary.setValue(25, {'p'}, 0);
dictionary.setValue(27, {'r'}, 0);
dictionary.setValue(96, {'Phi'}, 0);
dictionary.setValue(100, {'Theta'}, 0);
dictionary.setValue(153, {'Psi'}, 0);
dictionary.setValue(157, {'h'}, 0);

%Input variable limits Initializations
graphInitial.setLimits([], {'fseq1'}, [-30 0]);
graphInitial.setLimits([], {'Xt_c'}, [0 60]);
graphInitial.setLimits([], {'fseq2'}, [-0.5 0.5]);
graphInitial.setLimits([], {'da_c'}, [-0.5 0.5]);
graphInitial.setLimits([], {'fseq3'}, [-0.5 0.5]);
graphInitial.setLimits([], {'de_c'}, [-0.5 0.5]);
graphInitial.setLimits([], {'fseq4'}, [-0.5 0.5]);
graphInitial.setLimits([], {'dr_c'}, [-0.5 0.5]);
graphInitial.setLimits([], {'fseq5'}, [-5 5]);
graphInitial.setLimits([], {'fseq6'}, [-0.35 0.35]);
graphInitial.setLimits([], {'fseq7'}, [-0.35 0.35]);
graphInitial.setLimits([], {'fseq14'}, [-5 5]);
graphInitial.setLimits([], {'fseq15'}, [-0.1 0.1]);

%Measured variable limits Initializations
graphInitial.setLimits([], {'V_m'}, [14.99 15.01]);
graphInitial.setLimits([], {'a_m'}, [-0.785 -0.785]);
graphInitial.setLimits([], {'b_m'}, [-0.785 -0.785]);
graphInitial.setLimits([], {'p_m'}, [deg2rad([-360 360])]);
graphInitial.setLimits([], {'q_m'}, [deg2rad([-90 90])]);
graphInitial.setLimits([], {'r_m'}, [deg2rad([-90 90])]);
graphInitial.setLimits([], {'Psi_m'}, [deg2rad([-180 180])]);
graphInitial.setLimits([], {'Theta_m'}, [deg2rad([-90 90])]);
graphInitial.setLimits([], {'Phi_m'}, [deg2rad([-180 180])]);
graphInitial.setLimits([], {'h_m'}, [0 100]);
graphInitial.setLimits([], {'qbar_m'}, [1.1 1.3]);

end