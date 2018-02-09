function [ dictionary ] = makeDictionary_g031(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
%Input Initializations
dictionary.setValue(17, {'u1'}, 1);

%Measurement Initializations
dictionary.setValue(28, {'s1'}, 1);

%Fault Initializations
dictionary.setValue(2, {'fceq1'}, 0);
dictionary.setValue(13, {'fceq2'}, 0);
dictionary.setValue(20, {'fceq3'}, 0);
dictionary.setValue(26, {'fceq4'}, 0);

%State Initializations
dictionary.setValue(6, {'x1'}, 1);

%Input variable limits Initializations
graphInitial.setLimits([], {'fceq1'}, [-1 1]);
graphInitial.setLimits([], {'fceq2'}, [-1 1]);
graphInitial.setLimits([], {'u1'}, [-1 1]);
graphInitial.setLimits([], {'fceq3'}, [-1 1]);
graphInitial.setLimits([], {'fceq4'}, [-1 1]);

%Measured variable limits Initializations
graphInitial.setLimits([], {'s1'}, [-1 1]);

end