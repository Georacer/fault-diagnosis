function [ dictionary ] = makeDictionary_g014h(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variableIds);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

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
dictionary.setValue([], {'C_D_O'}, ?);
dictionary.setValue([], {'C_D_alpha'}, ?);
dictionary.setValue([], {'C_D_q'}, 0);
dictionary.setValue([], {'C_D_delta_e'}, 0);
dictionary.setValue([], {'C_Y_0'}, 0);
dictionary.setValue([], {'C_Y_beta'}, -0.98);
dictionary.setValue([], {'C_Y_p'}, 0);
dictionary.setValue([], {'C_Y_delta_r'}, -0.2);
dictionary.setValue([], {'C_L_0'}, 0.56);
dictionary.setValue([], {'C_L_alpha'}, 6.9);
dictionary.setValue([], {'C_L_q'}, 0);
dictionary.setValue([], {'C_L_delta_e'}, 0);
dictionary.setValue([], {'S'}, 0.45);
dictionary.setValue([], {'c'}, 0.24);
dictionary.setValue([], {'C_m_0'}, 0.045);
dictionary.setValue([], {'C_m_alpha'}, -0.7);
dictionary.setValue([], {'C_m_q'}, -20);
dictionary.setValue([], {'C_m_delta_e'}, 1.0);
dictionary.setValue([], {'J_mot'}, 0.008);
dictionary.setValue([], {'K_v'}, 13.333);
dictionary.setValue([], {'R_m'}, 0.041);
dictionary.setValue([], {'I_0'}, 0.9);
dictionary.setValue([], {'R_s'}, 0);
dictionary.setValue([], {'R_M'}, 6378139.844); % This is an approximation
dictionary.setValue([], {'R_N'}, 6345757.579); % This is an approximation
dictionary.setValue([], {'r_0'}, 6356766);
dictionary.setValue([], {'L_0'}, -0.0065);
dictionary.setValue([], {'M_0'}, 0.0289644);
dictionary.setValue([], {'R_star'}, 8.31432);
dictionary.setValue([], {'g_0'}, 9.799);

%Input Initializations
dictionary.setValue(529, {'ffeq26'}, 0);
dictionary.setValue(609, {'ffeq40'}, 0);
dictionary.setValue(619, {'ffeq41'}, 0);
dictionary.setValue(624, {'ffeq42'}, 0);
dictionary.setValue(638, {'ffeq44'}, 0);
dictionary.setValue(644, {'ffeq45'}, 0);
dictionary.setValue(652, {'ffeq46'}, 0);
dictionary.setValue(667, {'ffeq48'}, 0);
dictionary.setValue(675, {'ffeq49'}, 0);
dictionary.setValue(830, {'fseq1'}, 0);
dictionary.setValue(839, {'fseq2'}, 0);
dictionary.setValue(849, {'fseq3'}, 0);
dictionary.setValue(859, {'fseq4'}, 0);
dictionary.setValue(865, {'fseq5'}, 0);
dictionary.setValue(871, {'fseq6'}, 0);
dictionary.setValue(877, {'fseq7'}, 0);
dictionary.setValue(883, {'fseq8'}, 0);
dictionary.setValue(889, {'fseq9'}, 0);
dictionary.setValue(943, {'fseq22'}, 0);
dictionary.setValue(949, {'fseq23'}, 0);
dictionary.setValue(955, {'fseq24'}, 0);
dictionary.setValue(973, {'fseq28'}, 0);
dictionary.setValue(976, {'delta_a_inp'}, 0);
dictionary.setValue(979, {'fseq29'}, 0);
dictionary.setValue(982, {'delta_e_inp'}, 0);
dictionary.setValue(985, {'fseq30'}, 0);
dictionary.setValue(988, {'delta_t_inp'}, 0);
dictionary.setValue(991, {'fseq31'}, 0);
dictionary.setValue(994, {'delta_r_inp'}, 0);

%Measurement Initializations
dictionary.setValue(832, {'a_m_x'}, 0);
dictionary.setValue(841, {'a_m_y'}, 0);
dictionary.setValue(851, {'a_m_z'}, 0);
dictionary.setValue(861, {'p_m'}, 0);
dictionary.setValue(867, {'q_m'}, 0);
dictionary.setValue(873, {'r_m'}, 0);
dictionary.setValue(879, {'phi_m'}, 0);
dictionary.setValue(885, {'theta_m'}, 0);
dictionary.setValue(891, {'psi_m'}, 0);
dictionary.setValue(895, {'lat_0_gps'}, 0);
dictionary.setValue(899, {'lon_0_gps'}, 0);
dictionary.setValue(903, {'lat_gps'}, 0);
dictionary.setValue(907, {'lon_gps'}, 0);
dictionary.setValue(911, {'z_gps'}, 0);
dictionary.setValue(915, {'V_g_gps'}, 0);
dictionary.setValue(919, {'chi_gps'}, 0);
dictionary.setValue(923, {'T_0_m'}, 0);
dictionary.setValue(927, {'z_0_m'}, 0);
dictionary.setValue(935, {'P_bar'}, 0);
dictionary.setValue(939, {'T_m'}, 0);
dictionary.setValue(945, {'P_t_m'}, 0);
dictionary.setValue(951, {'alpha_m'}, 0);
dictionary.setValue(957, {'beta_m'}, 0);
dictionary.setValue(961, {'V_mot_m'}, 0);
dictionary.setValue(965, {'I_mot_m'}, 0);
dictionary.setValue(969, {'n_prop_m'}, 0);

%Fault Initializations
dictionary.setValue(529, {'ffeq26'}, 0);
dictionary.setValue(609, {'ffeq40'}, 0);
dictionary.setValue(619, {'ffeq41'}, 0);
dictionary.setValue(624, {'ffeq42'}, 0);
dictionary.setValue(638, {'ffeq44'}, 0);
dictionary.setValue(644, {'ffeq45'}, 0);
dictionary.setValue(652, {'ffeq46'}, 0);
dictionary.setValue(667, {'ffeq48'}, 0);
dictionary.setValue(675, {'ffeq49'}, 0);
dictionary.setValue(830, {'fseq1'}, 0);
dictionary.setValue(839, {'fseq2'}, 0);
dictionary.setValue(849, {'fseq3'}, 0);
dictionary.setValue(859, {'fseq4'}, 0);
dictionary.setValue(865, {'fseq5'}, 0);
dictionary.setValue(871, {'fseq6'}, 0);
dictionary.setValue(877, {'fseq7'}, 0);
dictionary.setValue(883, {'fseq8'}, 0);
dictionary.setValue(889, {'fseq9'}, 0);
dictionary.setValue(943, {'fseq22'}, 0);
dictionary.setValue(949, {'fseq23'}, 0);
dictionary.setValue(955, {'fseq24'}, 0);
dictionary.setValue(973, {'fseq28'}, 0);
dictionary.setValue(979, {'fseq29'}, 0);
dictionary.setValue(985, {'fseq30'}, 0);
dictionary.setValue(991, {'fseq31'}, 0);

%State Initializations
dictionary.setValue(4, {'phi'}, 0);
dictionary.setValue(6, {'theta'}, 0);
dictionary.setValue(8, {'psi'}, 0);
dictionary.setValue(10, {'u'}, 0);
dictionary.setValue(12, {'v'}, 0);
dictionary.setValue(14, {'w'}, 0);
dictionary.setValue(39, {'p'}, 0);
dictionary.setValue(41, {'q'}, 0);
dictionary.setValue(43, {'r'}, 0);
dictionary.setValue(596, {'n_prop'}, 0);
dictionary.setValue(687, {'north'}, 0);
dictionary.setValue(691, {'east'}, 0);
dictionary.setValue(695, {'down'}, 0);

end