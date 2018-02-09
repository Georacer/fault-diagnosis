%% Label each PSO by the subsystems it involves
% * This will probably involve labeling each model equation - Done

%% Print various stats in text format

fid = fopen('subsystems.txt','w+');
for i=1:length(SOSubgraphs)
    string = sprintf('SO #%i ',i);
    fprintf(fid, string);
    string = sprintf('%s, ', SOSubgraphs(i).reg.subsystems{:});
    fprintf(fid, '%s\n', string);
end
fclose(fid);


% X All PSOs of g014g include the subsystems: actuators, aerodynamics, airdata, athmosphere, constants, dynamics, earth, gravity, initializations, kinematics, mass, motor, propeller, sensors
% * Make a note on which PSOs we can implement, i.e. we have all of their
% parameters and measurements
% - All of the PSOs involve the same subsystems. Perhaps individual
% equations will make a difference?
% - SOSubgraphs are an MTES each
% X Check each free constraint in each MTES to see if they are all usable
% as residual generators
% - No, only some free constraints are sensitive to faulty equations, based
% on a given matching
% O Since some parts of an MTES are not used for generating residuals,
% perhaps matching validity should not be enforced on them.

% Plot subgraphs to check calculability of residuals

plotters = Plotter.empty;
for i=1:length(SOSubgraphs)
    fprintf('\n');
    disp('Examining another SOs')
    % Plot resulting matchings
    plotters(i) = Plotter(tempGI);
    plotters(i).plotDot(sprintf('PSO_%d_matched',i));
end

% X MTESs are all very large. This doesn't make sense, because some PSOs
% should be very compact yet observable. Investigate.
% - In g014e I had matched first-level sensory equations which were faulty,
% thus eliminating easy residuals. I created g014g which can be parsable
% with no Ranking
% O However, this too has only one very easy residual covering the motor. Investigate.
% - Perhaps the complex aerodynamics model doesn't let any other sensor
% fault to be observable.

% - Each MTES has multiple residual generators, sensitive to different
% faults each.
% O Extract each residual generator, its contributing elements and its
% fault signature. Compare across all MTESs.
% - See "printMatching"


% O If we are to find the full analytical isolation matrix we will have to
% "guess" the rest of the values, at best
% * Especially check the PSOs involving the AoS signal - check if it is
% available in the flight logs
% - Subgraph 3 is sensitive only to beta


%% Find a PSO which: (DROPPED)
% * Its cheapest relaxed matching is not feasible,
% * It has a feasible matching,
% * Involves interesting subsystems
% - SO(3) is a good case, which involves beta too

SOSubgraphs(3).adjacency.parseModel();
matrix = SOSubgraphs(3).adjacency.BD;
ids = [SOSubgraphs(3).reg.varIdArray SOSubgraphs(3).reg.equIdArray];
ccs = find_conn_comp(matrix);

id = 395;
membership = zeros(1,length(ccs));
for i=1:length(membership)
    if ismember(id,ids(ccs{i}))
        membership(i) = 1;
    end
end

%% Find a PSO which: (DROPPED)
% * Has no feasible matching (there is only 1 in g014e)
% - There are a few in g014g
% - SO(2) is an example

%%

length(graphInitial.getEdgeIdByProperty('isDerivative'))
length(graphInitial.getEdgeIdByProperty('isNonSolvable'))

% Average PSO size
numSets = length(ResGenSets);
total = 0;
for i=1:numSets
    total = total+length(ResGenSets{i});
end
avgSize = total/numSets

% Average matching size
numSets = length(matchers);
total = 0;
counter = 0;
for i=1:numSets
    matching = matchers(i).matchingSet;
    if ~isempty(matching)
        total = total+length(matching);
        counter = counter + 1;
    end
end
avgSize = total/counter

% PSOs without valid matchings
numSets = length(matchers);
total = 0;
counter = 0;
for i=1:numSets
    matching = matchers(i).matchingSet;
    if isempty(matching)
        counter = counter + 1;
    end
end
counter