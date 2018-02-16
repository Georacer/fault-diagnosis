function [ FSStruct ] = generateFSM( gi, res_gens_set, matchings_set )
%GENERATEFSM Generate the fault signature matrix and related data
%   INPUTS          :
%   gi              : The intial graph interface
%   ResGenSets_cell : A cell array containing all equations which contribute
%       to residual generators
%   matchings_set    : A cell array containing all matchings. Used to verify
%   that a residual generator is feasible.
%   OUTUPTS         :
%   FSStruct        : The struct containing the FSM and other data

% Get all the fault ids and aliases
fault_ids = gi.getVarIdByProperty('isFault');
fault_aliases = gi.getAliasById(fault_ids);

% Flatten the residual generator sets
residual_constraints = {};
counter = 1;
for i=1:length(res_gens_set)
    for j=1:length(res_gens_set{i})
        residual_constraints{counter} = res_gens_set{i}{j};
        counter = counter + 1;
    end
end

% Flatten the matchig sets
matchings = {};
counter = 1;
for i=1:length(matchings_set)
    for j=1:length(matchings_set{i})
        matchings{counter} = matchings_set{i}{j};
        counter = counter + 1;
    end
end

% Verify that both have the same size
assert(length(residual_constraints)==length(matchings),'Residuals do not all have a corresponding matching');

% Keep only the non-empty matchings
valid_matchings_mask = ~cellfun(@isempty, matchings);
valid_residual_constraints = residual_constraints(valid_matchings_mask);
valid_matchings = matchings(valid_matchings_mask);

% Initialize the FSM
FSM = zeros(length(matchings),length(fault_ids));

% Generate the fault signature for each residual
for i=1:size(FSM,1)
    if ~valid_matchings_mask(i)
        continue;
    end
    variable_ids = gi.getVariables(residual_constraints{i});
    FSM(i,:) = ismember(fault_ids, variable_ids);
end

% Find detectable faults
detectable_fault_ids = fault_ids(any(FSM,1));
non_detectable_fault_ids = setdiff(fault_ids, detectable_fault_ids);

% Build the output
FSStruct.FSM = FSM;
FSStruct.residual_constraints = residual_constraints;
FSStruct.valid_residual_constraints = valid_residual_constraints;
FSStruct.valid_matchings = valid_matchings;
FSStruct.valid_matchings_mask = valid_matchings_mask;
FSStruct.fault_ids = fault_ids;
FSStruct.fault_aliases = fault_aliases;
FSStruct.detectable_fault_ids = detectable_fault_ids;
FSStruct.non_detectable_fault_ids = non_detectable_fault_ids;

end

