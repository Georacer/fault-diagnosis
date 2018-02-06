function [ dictionary ] = makeDictionary_g014h(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
dictionary.setValue([], {'J6'}, 0.1204);
dictionary.setValue([], {'J7'}, 0);
dictionary.setValue([], {'J8'}, 1.759);
dictionary.setValue([], {'J3'}, 0);
dictionary.setValue([], {'J4'}, 1.135);
dictionary.setValue([], {'J5'}, 0);
dictionary.setValue([], {'J0'}, 0.8244);
dictionary.setValue([], {'J1'}, 0);
dictionary.setValue([], {'J2'}, 0.1204);
dictionary.setValue([], {'m'}, 2.0);
dictionary.setValue([], {'C_D_O'}, 0.01412); % This is an approximation
dictionary.setValue([], {'C_D_Alpha'}, 0.348); % This is an approximation
dictionary.setValue([], {'C_D_q'}, 0);
dictionary.setValue([], {'C_D_delta_e'}, 0);
dictionary.setValue([], {'C_Y_0'}, 0);
dictionary.setValue([], {'C_Y_Beta'}, -0.98);
dictionary.setValue([], {'C_Y_p'}, 0);
dictionary.setValue([], {'C_Y_delta_r'}, -0.2);
dictionary.setValue([], {'C_L_0'}, 0.56);
dictionary.setValue([], {'C_L_Alpha'}, 6.9);
dictionary.setValue([], {'C_L_q'}, 0);
dictionary.setValue([], {'C_L_delta_e'}, 0);
dictionary.setValue([], {'S'}, 0.45);
dictionary.setValue([], {'c'}, 0.24);
dictionary.setValue([], {'C_m_0'}, 0.045);
dictionary.setValue([], {'C_m_Alpha'}, -0.7);
dictionary.setValue([], {'C_m_q'}, -20);
dictionary.setValue([], {'C_m_delta_e'}, 1.0);
dictionary.setValue([], {'J_mot'}, 0.008);
dictionary.setValue([], {'K_v'}, 13.333);
dictionary.setValue([], {'R_m'}, 0.041);
dictionary.setValue([], {'I_0'}, 0.9);
dictionary.setValue([], {'R_s'}, 0);
dictionary.setValue([], {'M_0'}, 0.0289644);
dictionary.setValue([], {'R_star'}, 8.31432);
dictionary.setValue([], {'g_0'}, 9.799);

%Input Initializations
dictionary.setValue(585, {'ffeq41'}, 0);
dictionary.setValue(590, {'ffeq42'}, 0);
dictionary.setValue(604, {'ffeq44'}, 0);
dictionary.setValue(610, {'ffeq45'}, 0);
dictionary.setValue(618, {'ffeq46'}, 0);
dictionary.setValue(633, {'ffeq48'}, 0);
dictionary.setValue(641, {'ffeq49'}, 0);
dictionary.setValue(722, {'fseq1'}, 0);
dictionary.setValue(731, {'fseq2'}, 0);
dictionary.setValue(741, {'fseq3'}, 0);
dictionary.setValue(751, {'fseq4'}, 0);
dictionary.setValue(757, {'fseq5'}, 0);
dictionary.setValue(763, {'fseq6'}, 0);
dictionary.setValue(814, {'fseq17'}, 0);
dictionary.setValue(820, {'fseq18'}, 0);
dictionary.setValue(826, {'fseq19'}, 0);
dictionary.setValue(832, {'fseq20'}, 0);
dictionary.setValue(838, {'fseq21'}, 0);
dictionary.setValue(848, {'fseq23'}, 0);
dictionary.setValue(851, {'delta_a_inp'}, 0);
dictionary.setValue(854, {'fseq24'}, 0);
dictionary.setValue(857, {'delta_e_inp'}, 0);
dictionary.setValue(860, {'fseq25'}, 0);
dictionary.setValue(863, {'delta_t_inp'}, 0);
dictionary.setValue(866, {'fseq26'}, 0);
dictionary.setValue(869, {'delta_r_inp'}, 0);

%Measurement Initializations
dictionary.setValue(724, {'a_m_x'}, 0);
dictionary.setValue(733, {'a_m_y'}, 0);
dictionary.setValue(743, {'a_m_z'}, 0);
dictionary.setValue(753, {'p_m'}, 0);
dictionary.setValue(759, {'q_m'}, 0);
dictionary.setValue(765, {'r_m'}, 0);
dictionary.setValue(769, {'Phi_m'}, 0);
dictionary.setValue(773, {'Theta_m'}, 0);
dictionary.setValue(777, {'Psi_m'}, 0);
dictionary.setValue(781, {'lat_0_gps'}, 0);
dictionary.setValue(786, {'lon_0_gps'}, 0);
dictionary.setValue(791, {'lat_gps'}, 0);
dictionary.setValue(796, {'lon_gps'}, 0);
dictionary.setValue(801, {'z_gps'}, 0);
dictionary.setValue(805, {'T_0_m'}, 0);
dictionary.setValue(810, {'z_0_gps'}, 0);
dictionary.setValue(816, {'P_bar'}, 0);
dictionary.setValue(822, {'T_m'}, 0);
dictionary.setValue(828, {'P_t_m'}, 0);
dictionary.setValue(834, {'Alpha_m'}, 0);
dictionary.setValue(840, {'Beta_m'}, 0);
dictionary.setValue(844, {'n_prop_m'}, 0);

%Fault Initializations
dictionary.setValue(585, {'ffeq41'}, 0);
dictionary.setValue(590, {'ffeq42'}, 0);
dictionary.setValue(604, {'ffeq44'}, 0);
dictionary.setValue(610, {'ffeq45'}, 0);
dictionary.setValue(618, {'ffeq46'}, 0);
dictionary.setValue(633, {'ffeq48'}, 0);
dictionary.setValue(641, {'ffeq49'}, 0);
dictionary.setValue(722, {'fseq1'}, 0);
dictionary.setValue(731, {'fseq2'}, 0);
dictionary.setValue(741, {'fseq3'}, 0);
dictionary.setValue(751, {'fseq4'}, 0);
dictionary.setValue(757, {'fseq5'}, 0);
dictionary.setValue(763, {'fseq6'}, 0);
dictionary.setValue(814, {'fseq17'}, 0);
dictionary.setValue(820, {'fseq18'}, 0);
dictionary.setValue(826, {'fseq19'}, 0);
dictionary.setValue(832, {'fseq20'}, 0);
dictionary.setValue(838, {'fseq21'}, 0);
dictionary.setValue(848, {'fseq23'}, 0);
dictionary.setValue(854, {'fseq24'}, 0);
dictionary.setValue(860, {'fseq25'}, 0);
dictionary.setValue(866, {'fseq26'}, 0);

%State Initializations
dictionary.setValue(4, {'Phi'}, 0);
dictionary.setValue(6, {'Theta'}, 0);
dictionary.setValue(8, {'Psi'}, 0);
dictionary.setValue(10, {'u'}, 0);
dictionary.setValue(12, {'v'}, 0);
dictionary.setValue(14, {'w'}, 0);
dictionary.setValue(39, {'p'}, 0);
dictionary.setValue(41, {'q'}, 0);
dictionary.setValue(43, {'r'}, 0);
dictionary.setValue(564, {'n_prop'}, 0);
dictionary.setValue(653, {'north'}, 0);
dictionary.setValue(657, {'east'}, 0);
dictionary.setValue(661, {'down'}, 0);

end