function [  ] = validateMatchings( SA_results, SA_settings )
%VALIDATEMATCHINGS Check if all matchings found are realizable
%   Detailed explanation goes here

%TODO fix for multiple subgraphs

PSOs = SA_results.SOSubgraphs_set{1}; % Capture all of the PSOs of a subgraph
matchings = SA_results.matchings_set{1}; % Capture all of the matchings

valid_matchings = 0;
total_matching_array = zeros(1,length(matchings)); % Holds the total number of generated matchings
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
    total_matching_array(i) = length(matchings_this_pso); % Count the matchings of this PSO
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
        
        valid_matchings = valid_matchings + 1; % Cound the valid matchings
        valid_matching_cell{i}{end+1} = m; % Store this valid matching in this PSO container
        %                     break; % One valid matching was found for this PSO. This is enough
    end
end

%             fprintf('Valid matchings %d/%d\n',valid_matchings, length(matchings));

%% Display the total number of residual generators found

fprintf('Matching Statistics for system %s with method %s\n',SA_results.gi.name, SA_settings.matchMethod);
fprintf('================================================\n');

fprintf('Number of PSOs with valid matchings: %d/%d\n',sum(valid_pso_array),length(valid_pso_array));

graphName = SA_results.gi.name;

% Average PSO size
numSets = 0;
for i=1:length(SA_results.stats.(graphName).ResGenSets)
    numSets = numSets + length(SA_results.stats.(graphName).ResGenSets{i});
end
%             fprintf('Total number of PSOs: %d\n',numSets);

total = 0;
for j=1:length(SA_results.stats.(graphName).ResGenSets)
    for i=1:length(SA_results.stats.(graphName).ResGenSets{j})
        total = total+length(SA_results.stats.(graphName).ResGenSets{j}{i});
    end
end
avgSize = total/numSets;
fprintf('Average PSO size: %g\n',avgSize);

% Average matching size
total = 0;
for i=1:1
    for j=1:length(valid_matching_cell) % Select subgraph
        matchings_this_pso = valid_matching_cell{j}; % Select PSO
        for k=1:length(matchings_this_pso) % Select matching
            matching = matchings_this_pso{k};
            if ~isempty(matching)
                total = total+length(matching);
            else
            end
        end
    end
end
avgSize = total/valid_matchings;
fprintf('Number of resulting valid matchings: %d\n',valid_matchings);
fprintf('Mean matching size: %g\n',avgSize);
fprintf('Number of invalid matchings: %d\n',sum(total_matching_array)-valid_matchings);
fprintf('\n');

% Initial PSO matching statistics
if exist('offendingInitial','var')
    validInitial = sum(cellfun(@(x) isempty(x),offendingInitial));
    fprintf('Number of valid initial, relaxed matchings: %d\n', validInitial);
    
    counterInt = 0;
    counterDer = 0;
    counterNI = 0;
    for i=1:length(offendingInitial)
        edgesOffending = offendingInitial{i};
        if isempty(edgesOffending)
            continue;
        end
        if any(SA_results.gi.isDerivative(edgesOffending))
            counterDer = counterDer+1;
        end
        if any(SA_results.gi.isIntegral(edgesOffending))
            counterInt = counterInt+1;
        end
        if any(SA_results.gi.isNonSolvable(edgesOffending))
            counterNI = counterNI+1;
        end
    end
    
    fprintf('Number of initial matching containing invalid derivative edges: %d\n',counterDer);
    fprintf('Number of initial matching containing invalid integral edges: %d\n',counterInt);
    fprintf('Number of initial matching containing invalid non-invertible edges: %d\n',counterNI);
    
end

end

