function [ dictionary ] = makeDictionary_g041(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
dictionary.setValue([], {'m'}, 13.5);
dictionary.setValue([], {'G1'}, 0.1215);
dictionary.setValue([], {'G2'}, 0.7747);
dictionary.setValue([], {'G5'}, 0.8534);
dictionary.setValue([], {'G6'}, 0.1061);
dictionary.setValue([], {'G7'}, -0.1683);
dictionary.setValue([], {'g'}, 9.81);
dictionary.setValue([], {'rho'}, 1.225);
dictionary.setValue([], {'S'}, 0.55);
dictionary.setValue([], {'c'}, 0.18994);
dictionary.setValue([], {'Cy0'}, 0);
dictionary.setValue([], {'Cyb'}, -0.98);
dictionary.setValue([], {'Cyp'}, 0);
dictionary.setValue([], {'Cyr'}, 0);
dictionary.setValue([], {'Cyda'}, 0);
dictionary.setValue([], {'Cydr'}, -0.17);
dictionary.setValue([], {'b'}, 2.8956);
dictionary.setValue([], {'Sprop'}, 0.2027);
dictionary.setValue([], {'Cprop'}, 1);
dictionary.setValue([], {'Kmotor'}, 80);
dictionary.setValue([], {'Jy'}, 1.135);
dictionary.setValue([], {'G3'}, 1.2253);
dictionary.setValue([], {'Cl0'}, 0);
dictionary.setValue([], {'G4'}, 0.0839);
dictionary.setValue([], {'Cn0'}, 0);
dictionary.setValue([], {'Clb'}, -0.12);
dictionary.setValue([], {'Cnb'}, 0.25);
dictionary.setValue([], {'Clp'}, -0.26);
dictionary.setValue([], {'Cnp'}, 0.022);
dictionary.setValue([], {'Clr'}, 0.14);
dictionary.setValue([], {'Cnr'}, -0.35);
dictionary.setValue([], {'Clda'}, 0.08);
dictionary.setValue([], {'Cnda'}, 0.06);
dictionary.setValue([], {'Cldr'}, 0.105);
dictionary.setValue([], {'Cndr'}, -0.032);
dictionary.setValue([], {'G8'}, 0.5742);
dictionary.setValue([], {'CDq'}, 0);
dictionary.setValue([], {'CLq'}, 0);
dictionary.setValue([], {'CDde'}, 0);
dictionary.setValue([], {'CLde'}, -0.36);
dictionary.setValue([], {'CL0'}, 0.28);
dictionary.setValue([], {'CLa'}, 3.45);
dictionary.setValue([], {'CD0'}, 0.03);
dictionary.setValue([], {'CDa'}, 0.30);

%Input Initializations
dictionary.setValue([], {'dtc'}, 0);
dictionary.setValue([], {'dac'}, 0);
dictionary.setValue([], {'dec'}, 0);
dictionary.setValue([], {'drc'}, 0);

%Measurement Initializations
dictionary.setValue([], {'Vam'}, 0);
dictionary.setValue([], {'pm'}, 0);
dictionary.setValue([], {'qm'}, 0);
dictionary.setValue([], {'rm'}, 0);
dictionary.setValue([], {'Phim'}, 0);
dictionary.setValue([], {'Thetam'}, 0);
dictionary.setValue([], {'Psim'}, 0);

%Fault Initializations
dictionary.setValue([], {'fseq1'}, 0);
dictionary.setValue([], {'fseq2'}, 0);
dictionary.setValue([], {'fseq3'}, 0);
dictionary.setValue([], {'fseq4'}, 0);
dictionary.setValue([], {'fseq5'}, 0);
dictionary.setValue([], {'fseq6'}, 0);
dictionary.setValue([], {'fseq7'}, 0);
dictionary.setValue([], {'fseq8'}, 0);
dictionary.setValue([], {'fseq9'}, 0);
dictionary.setValue([], {'fseq10'}, 0);
dictionary.setValue([], {'fseq11'}, 0);

%Disturbances Initializations
%State Initializations
dictionary.setValue([], {'u'}, 0);
dictionary.setValue([], {'v'}, 0);
dictionary.setValue([], {'w'}, 0);
dictionary.setValue([], {'Phi'}, 0);
dictionary.setValue([], {'Theta'}, 0);
dictionary.setValue([], {'Psi'}, 0);
dictionary.setValue([], {'p'}, 0);
dictionary.setValue([], {'q'}, 0);
dictionary.setValue([], {'r'}, 0);
dictionary.setValue([], {'pn'}, 0);
dictionary.setValue([], {'pe'}, 0);
dictionary.setValue([], {'h'}, 0);

%Input variable limits Initializations
graphInitial.setLimits([], {'fseq1'}, [-1 1]);
graphInitial.setLimits([], {'dtc'}, [-1 1]);
graphInitial.setLimits([], {'fseq2'}, [-1 1]);
graphInitial.setLimits([], {'dac'}, [-1 1]);
graphInitial.setLimits([], {'fseq3'}, [-1 1]);
graphInitial.setLimits([], {'dec'}, [-1 1]);
graphInitial.setLimits([], {'fseq4'}, [-1 1]);
graphInitial.setLimits([], {'drc'}, [-1 1]);
graphInitial.setLimits([], {'fseq5'}, [-1 1]);
graphInitial.setLimits([], {'fseq6'}, [-1 1]);
graphInitial.setLimits([], {'fseq7'}, [-1 1]);
graphInitial.setLimits([], {'fseq8'}, [-1 1]);
graphInitial.setLimits([], {'fseq9'}, [-1 1]);
graphInitial.setLimits([], {'fseq10'}, [-1 1]);
graphInitial.setLimits([], {'fseq11'}, [-1 1]);

%Measured variable limits Initializations
graphInitial.setLimits([], {'Vam'}, [-1 1]);
graphInitial.setLimits([], {'pm'}, [-1 1]);
graphInitial.setLimits([], {'qm'}, [-1 1]);
graphInitial.setLimits([], {'rm'}, [-1 1]);
graphInitial.setLimits([], {'Phim'}, [-1 1]);
graphInitial.setLimits([], {'Thetam'}, [-1 1]);
graphInitial.setLimits([], {'Psim'}, [-1 1]);

end