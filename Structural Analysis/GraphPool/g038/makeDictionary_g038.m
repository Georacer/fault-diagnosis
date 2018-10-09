function [ dictionary ] = makeDictionary_g038(graphInitial)
variable_ids = graphInitial.getVariables();
variable_aliases = graphInitial.getAliasById(variable_ids);
dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));

%Parameter Initializations
%Input Initializations
%Measurement Initializations
dictionary.setValue(13, {'y_1'}, 0);
dictionary.setValue(19, {'y_2'}, 0);

%Fault Initializations
dictionary.setValue(9, {'ffeq1'}, 0);

%Disturbances Initializations
dictionary.setValue(16, {'d_1'}, 0);
dictionary.setValue(23, {'d_2'}, 0);

%State Initializations
%Input variable limits Initializations
graphInitial.setLimits([], {'ffeq1'}, [-1 1]);
graphInitial.setLimits([], {'d_1'}, [-1 1]);
graphInitial.setLimits([], {'d_2'}, [-1 1]);

%Measured variable limits Initializations
graphInitial.setLimits([], {'y_1'}, [-1 1]);
graphInitial.setLimits([], {'y_2'}, [-1 1]);

end