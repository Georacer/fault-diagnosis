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
dictionary.setValue([], {'S'}, 0.45);
dictionary.setValue([], {'C_D_0'}, 0.01412); % This is an approximation
dictionary.setValue([], {'C_D_Alpha'}, 0.348); % This is an approximation
dictionary.setValue([], {'C_D_q'}, 0);
dictionary.setValue([], {'C_D_delta_e'}, 0);
dictionary.setValue([], {'c'}, 0.24);
dictionary.setValue([], {'C_Y_0'}, 0);
dictionary.setValue([], {'C_Y_Beta'}, -0.98);
dictionary.setValue([], {'C_Y_p'}, 0);
dictionary.setValue([], {'C_Y_delta_r'}, -0.2);
dictionary.setValue([], {'b'}, 1.88);
dictionary.setValue([], {'C_L_0'}, 0.56);
dictionary.setValue([], {'C_L_Alpha'}, 6.9);
dictionary.setValue([], {'C_L_q'}, 0);
dictionary.setValue([], {'C_L_delta_e'}, 0);
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
dictionary.setValue(594, {'ffeq41'}, 0);
dictionary.setValue(599, {'ffeq42'}, 0);
dictionary.setValue(613, {'ffeq44'}, 0);
dictionary.setValue(619, {'ffeq45'}, 0);
dictionary.setValue(627, {'ffeq46'}, 0);
dictionary.setValue(642, {'ffeq48'}, 0);
dictionary.setValue(650, {'ffeq49'}, 0);
dictionary.setValue(731, {'fseq1'}, 0);
dictionary.setValue(740, {'fseq2'}, 0);
dictionary.setValue(750, {'fseq3'}, 0);
dictionary.setValue(760, {'fseq4'}, 0);
dictionary.setValue(766, {'fseq5'}, 0);
dictionary.setValue(772, {'fseq6'}, 0);
dictionary.setValue(823, {'fseq17'}, 0);
dictionary.setValue(829, {'fseq18'}, 0);
dictionary.setValue(835, {'fseq19'}, 0);
dictionary.setValue(841, {'fseq20'}, 0);
dictionary.setValue(847, {'fseq21'}, 0);
dictionary.setValue(857, {'fseq23'}, 0);
dictionary.setValue(860, {'delta_a_inp'}, 0);
dictionary.setValue(863, {'fseq24'}, 0);
dictionary.setValue(866, {'delta_e_inp'}, 0);
dictionary.setValue(869, {'fseq25'}, 0);
dictionary.setValue(872, {'delta_t_inp'}, 0);
dictionary.setValue(875, {'fseq26'}, 0);
dictionary.setValue(878, {'delta_r_inp'}, 0);

%Measurement Initializations
dictionary.setValue(733, {'a_m_x'}, 0);
dictionary.setValue(742, {'a_m_y'}, 0);
dictionary.setValue(752, {'a_m_z'}, 0);
dictionary.setValue(762, {'p_m'}, 0);
dictionary.setValue(768, {'q_m'}, 0);
dictionary.setValue(774, {'r_m'}, 0);
dictionary.setValue(778, {'Phi_m'}, 0);
dictionary.setValue(782, {'Theta_m'}, 0);
dictionary.setValue(786, {'Psi_m'}, 0);
dictionary.setValue(790, {'lat_0_gps'}, 0);
dictionary.setValue(795, {'lon_0_gps'}, 0);
dictionary.setValue(800, {'lat_gps'}, 0);
dictionary.setValue(805, {'lon_gps'}, 0);
dictionary.setValue(810, {'z_gps'}, 0);
dictionary.setValue(814, {'T_0_m'}, 0);
dictionary.setValue(819, {'z_0_gps'}, 0);
dictionary.setValue(825, {'P_bar'}, 0);
dictionary.setValue(831, {'T_m'}, 0);
dictionary.setValue(837, {'P_t_m'}, 0);
dictionary.setValue(843, {'Alpha_m'}, 0);
dictionary.setValue(849, {'Beta_m'}, 0);
dictionary.setValue(853, {'n_prop_m'}, 0);

%Fault Initializations
dictionary.setValue(594, {'ffeq41'}, 0);
dictionary.setValue(599, {'ffeq42'}, 0);
dictionary.setValue(613, {'ffeq44'}, 0);
dictionary.setValue(619, {'ffeq45'}, 0);
dictionary.setValue(627, {'ffeq46'}, 0);
dictionary.setValue(642, {'ffeq48'}, 0);
dictionary.setValue(650, {'ffeq49'}, 0);
dictionary.setValue(731, {'fseq1'}, 0);
dictionary.setValue(740, {'fseq2'}, 0);
dictionary.setValue(750, {'fseq3'}, 0);
dictionary.setValue(760, {'fseq4'}, 0);
dictionary.setValue(766, {'fseq5'}, 0);
dictionary.setValue(772, {'fseq6'}, 0);
dictionary.setValue(823, {'fseq17'}, 0);
dictionary.setValue(829, {'fseq18'}, 0);
dictionary.setValue(835, {'fseq19'}, 0);
dictionary.setValue(841, {'fseq20'}, 0);
dictionary.setValue(847, {'fseq21'}, 0);
dictionary.setValue(857, {'fseq23'}, 0);
dictionary.setValue(863, {'fseq24'}, 0);
dictionary.setValue(869, {'fseq25'}, 0);
dictionary.setValue(875, {'fseq26'}, 0);

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
dictionary.setValue(573, {'n_prop'}, 0);
dictionary.setValue(662, {'north'}, 0);
dictionary.setValue(666, {'east'}, 0);
dictionary.setValue(670, {'down'}, 0);

end