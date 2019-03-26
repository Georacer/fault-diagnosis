function [ valid_pso_array, valid_matching_cell ] = validateMatchings( SA_results, SA_settings )
%VALIDATEMATCHINGS Check if all matchings found are realizable
%   Detailed explanation goes here

%TODO Does not apply for graphs with disconnected subgraphs

PSOs = SA_results.SOSubgraphs_set{1}; % Capture all of the PSOs of a subgraph
matchings = SA_results.matchings_set{1}; % Capture all of the matchings

valid_pso_array = zeros(1,length(PSOs)); % Holds the flags on which psos have a realizable matching
valid_matching_cell = cell(1,length(PSOs)); % Holds all of the valid matchings of each PSO

graphInitial = SA_results.gi; % Get the handle of the initial (unmatched) graph

% For each PSO
for i=1:length(matchings)
    if isempty(matchings{i})
        % No matching was found
        continue;
    end
    
    gi = PSOs(i); % Get the GraphInterface handle
    gi_blob = getByteStreamFromArray(gi); % Freeze a copy of this PSO
    matchings_this_pso = matchings{i}; % Get the matchings of this PSO
    if ~iscell(matchings_this_pso)
        matchings_this_pso = {matchings_this_pso};
    end
    valid_matching_cell{i} = {};
    
    valid_found = false;
    
    % For each matching
    for j=1:length(matchings_this_pso)
        gi = getArrayFromByteStream(gi_blob); % Restore the PSO
        m = matchings_this_pso{j}; % Get the current matching
        gi.applyMatching(m); % Apply the current matching to it
        
        % Ensure that the matching is perfect
        equIds = gi.getEquations(m);
        varIds = graphInitial.getVariablesUnknown(equIds);
        if length(varIds)~=length(equIds)
            continue;
        end
        
        % Run the Validator method on the matching
        gi.createAdjacency();
        adjacency = gi.adjacency;
        numVars = gi.adjacency.numVars;
        numEqs = gi.adjacency.numEqs;
        validator = Validator(adjacency.BD, adjacency.BD_types, numVars, numEqs);
        offendingEdges = validator.isValid();
        if ~isempty(offendingEdges)
            % Matching is not valid
            continue;
        end
        % Mark this PSO as one with a valid matching
        if ~valid_found
            valid_pso_array(i) = 1;
            valid_found = true;
        end
        
        valid_matching_cell{i}{end+1} = m; % Store this valid matching in this PSO container
    end
end

end

