function [ RE_results ] = get_res_gens( SA_results, RG_settings )
%GET_RES_GENS Implement the residual generators induced from a fully-directed structural graph
%   INPUTS:
%   SA_results  : The Structural Analysis results, as produced by structural_analysis()
%   RG_settings : The algorithm settings structure
%       dt          : The time-stemp used when implementing dynamic residuals
%   OUTPUTS:
%   RE_results  : The results structure
%       res_gen_cell: ResidualGenerator objects set
%       values      : Dictionary object, containing parameters for the model and variable values

%% Unpack the input argument

gi = SA_results.gi;  % This is the initial graph interface
SOSubgraphs_set = SA_results.SOSubgraphs_set;  % The set of all Structurally Overdetermined subgraphs
matchings_set = SA_results.matchings_set;

dt = RG_settings.dt;  % The time step, if needed

% Flatten the SOSubgraphs sets
SOSubgraphs = {};
counter = 1;
for i=1:length(SOSubgraphs_set)
    for j=1:length(SOSubgraphs_set{i})
        SOSubgraphs{counter} = SOSubgraphs_set{i}(j);
        counter = counter + 1;
    end
end

% Flatten the matching sets
matchings = {};
counter = 1;
for i=1:length(matchings_set)
    for j=1:length(matchings_set{i})
        matchings{counter} = matchings_set{i}{j};
        counter = counter + 1;
    end
end


%% Generate the solution orders

solutionOrder = cell(1,length(matchings));

for i=1:length(matchings)
    if isempty(matchings{i}) % No available matching
        continue
    end
    RGid = findResGenerators(SOSubgraphs{i},true);
    SCCs = findCalcSequence(SOSubgraphs{i}, 'asResGenerator', true);
    solutionOrder{i} = SCCs;
end

% return

%% Create dictionary with values
dict_name = sprintf('makeDictionary_%s(gi)',gi.name);
eval(['values = ' dict_name ';']);

%% Generate the residual generators

res_gen_cell = cell(1,length(solutionOrder));


% Disable deprecation warnings. These are thrown by instantiation of
% symbolic expression from strings
warning('off', 'symbolic:sym:sym:DeprecateExpressions'); % This is bugged and may suppress all warnings

tic
h = waitbar(0,'Implementing residual generators');
% Iterate over all solutionOrders
for i=1:length(solutionOrder)
    % Skip problematic SCCs
    if ismember(i,[0])
        error('I should not be here');
    end
    
    waitbar(i/length(solutionOrder),h);
    if isempty(solutionOrder{i})
        warning('Solution order was empty');
        continue;
    end
    
    SCCs = solutionOrder{i};
    matched_graph = SOSubgraphs{i};
    
    % Create the residual generator
    res_gen_cell{i} = ResidualGenerator(gi, matched_graph, SCCs, copy(values), dt);
    % Test if evaluator managed to instantiate
    if res_gen_cell{i}.has_failed
        res_gen_cell{i} = [];
        warning('Residual generator %d failed to instantiate',i);
    end
    
end
close(h);
toc

%% Build results

RE_results.res_gen_cell = res_gen_cell;
RE_results.values = values;

return

end

