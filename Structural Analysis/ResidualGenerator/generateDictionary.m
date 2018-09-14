function [  ] = generateDictionary( graphInterface )
%GENERATE_PARAMETER_LIST Generate a parameter setter function
%   This function will initialize the variable dictionary for the model.
%   The file will be created in the model subfolder.
%   IMPORTANT: Edit the file to set parameter values

gi = graphInterface;

folderName = sprintf('GraphPool/%s', gi.name);
if ~exist(folderName,'dir')
    error('Graph folder does not exist');
end
filePath = sprintf('GraphPool/%s/makeDictionary_%s.m',gi.name, gi.name);

if exist(filePath, 'file')
    backupName = sprintf('GraphPool/%s/makeDictionary_%s_old.m',gi.name, gi.name);
    movefile(filePath, backupName);
end
    

fileID = fopen(filePath,'w');

% Write header
s = sprintf('function [ dictionary ] = makeDictionary_%s(graphInitial)\n',gi.name); fprintf(fileID,s);
s = sprintf('%%makeDictionary Initialize the dictionary for the %s model\n',gi.name); fprintf(fileID,s);

% Initialize dictionary
s = 'variable_ids = graphInitial.getVariables();\n'; fprintf(fileID,s);
s = 'variable_aliases = graphInitial.getAliasById(variable_ids);\n'; fprintf(fileID,s);
s = 'dictionary = Dictionary(variable_ids, variable_aliases, inf*ones(size(variable_ids)));\n'; fprintf(fileID,s);
s = '\n';  fprintf(fileID,s);

% Generate parameter set calls
s = '%%Parameter Initializations\n'; fprintf(fileID,s);
parameter_ids = gi.getVarIdByProperty('isParameter');
if ~isempty(parameter_ids)
    parameter_aliases = gi.getAliasById(parameter_ids);
    for i=1:length(parameter_ids)
        s = sprintf('dictionary.setValue([], {''%s''}, ?);\n', parameter_aliases{i}); fprintf(fileID, s);
    end
    s = '\n';  fprintf(fileID,s);
end

% Initialize inputs to 0
s = '%%Input Initializations\n'; fprintf(fileID,s);
input_ids = gi.getVarIdByProperty('isInput');
fault_ids = gi.getVarIdByProperty('isFault');
dist_ids = gi.getVarIdByProperty('isDisturbance');
ids = setdiff(input_ids,[fault_ids dist_ids]);  % Leave faults out, will be covered later.
if ~isempty(ids)
    aliases = gi.getAliasById(ids);
    for i=1:length(ids)
        s = sprintf('dictionary.setValue(%d, {''%s''}, 0);\n', ids(i), aliases{i}); fprintf(fileID, s);
    end
    s = '\n';  fprintf(fileID,s);
end

% Initialize measurements to 0
s = '%%Measurement Initializations\n'; fprintf(fileID,s);
measurement_ids = gi.getVarIdByProperty('isMeasured');
measured_aliases = gi.getAliasById(measurement_ids);
for i=1:length(measurement_ids)
    s = sprintf('dictionary.setValue(%d, {''%s''}, 0);\n', measurement_ids(i), measured_aliases{i}); fprintf(fileID, s);
end
s = '\n';  fprintf(fileID,s);

% Initialize faults to 0
s = '%%Fault Initializations\n'; fprintf(fileID,s);
fault_ids = gi.getVarIdByProperty('isFault');
fault_aliases = gi.getAliasById(fault_ids);
for i=1:length(fault_ids)
    s = sprintf('dictionary.setValue(%d, {''%s''}, 0);\n', fault_ids(i), fault_aliases{i}); fprintf(fileID, s);
end
s = '\n';  fprintf(fileID,s);

% Initialize disturbances to 0
s = '%%Disturbances Initializations\n'; fprintf(fileID,s);
disturbance_ids = gi.getVarIdByProperty('isDisturbance');
disturbance_aliases = gi.getAliasById(disturbance_ids);
for i=1:length(disturbance_ids)
    s = sprintf('dictionary.setValue(%d, {''%s''}, 0);\n', disturbance_ids(i), disturbance_aliases{i}); fprintf(fileID, s);
end
s = '\n';  fprintf(fileID,s);

% Initialize states to 0
s = '%%State Initializations\n'; fprintf(fileID,s);
integral_edge_ids = gi.getEdgeIdByProperty('isIntegral');
state_ids = gi.getVariables(integral_edge_ids);
if ~isempty(state_ids)
    state_aliases = gi.getAliasById(state_ids);
    for i=1:length(state_ids)
        s = sprintf('dictionary.setValue(%d, {''%s''}, 0);\n', state_ids(i), state_aliases{i}); fprintf(fileID, s);
    end
    s = '\n';  fprintf(fileID,s);
end

% Create input variable limits setters
s = '%%Input variable limits Initializations\n'; fprintf(fileID,s);
input_ids = gi.getVarIdByProperty('isInput');
input_aliases = gi.getAliasById(input_ids);
for i=1:length(input_ids)
    s = sprintf('graphInitial.setLimits([], {''%s''}, [-1 1]);\n', input_aliases{i}); fprintf(fileID, s);
end
s = '\n';  fprintf(fileID,s);

% Create measured variable limits setters
s = '%%Measured variable limits Initializations\n'; fprintf(fileID,s);
measurement_ids = gi.getVarIdByProperty('isMeasured');
measured_aliases = gi.getAliasById(measurement_ids);
for i=1:length(measurement_ids)
    s = sprintf('graphInitial.setLimits([], {''%s''}, [-1 1]);\n', measured_aliases{i}); fprintf(fileID, s);
end
s = '\n';  fprintf(fileID,s);

s = 'end'; fprintf(fileID,s);

fclose(fileID);

end

