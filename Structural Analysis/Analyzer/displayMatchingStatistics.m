function [ ] = displayMatchingStatistics( SA_results, SA_settings, valid_pso_array, valid_matching_cell )
%DISPLAYMATCHINGSTATISTICS Display the total number of residual generators found
%   Detailed explanation goes here

% TODO Will not work for models with more than one disconnected subgraph

fprintf('Matching Statistics for system %s with method %s\n',SA_results.gi.name, SA_settings.matchMethod);
fprintf('================================================\n');

fprintf('Number of PSOs with valid matchings: %d/%d\n',sum(valid_pso_array),length(valid_pso_array));

graphName = SA_results.gi.name;

% Average PSO size
numSets = 0;
for i=1:length(SA_results.stats.(graphName).ResGenSets)
    numSets = numSets + length(SA_results.stats.(graphName).ResGenSets{i});
end
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
valid_matchings = 0;
original_matching_array = SA_results.matchings_set;
for i=1:1
    total_matching_array = zeros(1,length(original_matching_array{i})); % Holds the total number of generated matchings
    for j=1:length(valid_matching_cell) % Select subgraph
        matchings_this_pso = valid_matching_cell{j}; % Select PSO
        total_matching_array(j) = length(original_matching_array{i}{j}); % Count the matchings of this PSO
        
        for k=1:length(matchings_this_pso) % Select matching
            matching = matchings_this_pso{k};
            if ~isempty(matching)
                total = total+length(matching);
                valid_matchings = valid_matchings + 1;
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

end

