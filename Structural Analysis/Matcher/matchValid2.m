function [ M ] = matchValid2( matcher, varargin )
%MATCHVALID Find valid residuals in provided PSO
%   Extends matchValid: is also applicable in MTESs
%   Assumes the related graph is an MTES

p = inputParser;

p.addRequired('matcher',@(x) true);
p.addParameter('faultsOnly',true, @islogical);
p.addParameter('maxMSOsExamined', 0, @isnumeric);
p.addParameter('matchingsPerMSO', 0, @isnumeric);
p.addParameter('exitAtFirstValid', true, @islogical);

p.parse(matcher, varargin{:});
opts = p.Results;

faultsOnly = opts.faultsOnly; % Generate only residuals which are sensitive to faults
maxMSOsExamined = opts.maxMSOsExamined;
matchingsPerMSO = opts.matchingsPerMSO;
exitAtFirstValid = opts.exitAtFirstValid;

% debug = false;
debug = true;

gi = matcher.gi;
% Initialize valid matchings container
M = [];

eqsFaultable = gi.getEquIdByProperty('isFaultable');
if (faultsOnly && isempty(eqsFaultable))
    if debug; fprintf('matchValid2: The provided PSO is not susceptible to faults, and faultsOnly flag is true\n'); end
    return;
end

% Check if provided graph contains only unknown variables
if ~(isempty(gi.getMatchedEqus()) && isempty(gi.getMatchedVars()))
    error('Expecting a completely unknown subgraph to match');
end

% Check if structural redundancy degree is 1
equIds = gi.reg.equIdArray;
numEqs = length(equIds);
numVars = gi.graph.numVars;
redundancyDegree = numEqs-numVars;
assert(redundancyDegree>0,'Provided graph is not redundant');

% Create liusm model and extract MSOs
if redundancyDegree==1
    msoSet = {equIds};
else
    liuSM = createLiusm(gi);
    liuSM.CompiledMSO(); % Switch to compiled implementation
    liuSMMSO = liuSM.MSO();
    msoSet = cell(1,length(liuSMMSO));
    for i=1:length(liuSMMSO)
        msoSet(i) = {equIds(liuSMMSO{i})};
    end
    clear liuSM
end

% Keep only MSOs with a fault, if required
if faultsOnly
    for i=length(msoSet):-1:1
        if isempty(gi.isFaultable(msoSet{i}))
            msoSet(i) = [];
        end
    end
end


% Loop over the collected MSOs
MSOsExamined = 0;
PSOCosts = inf*ones(1,0);
PSOMatchings = cell(1,0);
examination_array = zeros(1,length(msoSet));
valid_matching_found = false;
for i=1:length(msoSet)
    if debug; fprintf('matchValid2: Testing MSO %d/%d with size %d\n',i,length(msoSet),length(msoSet{i})); end
    
    % Test for faultable equations
    if faultsOnly
        eqsFaultable = gi.isFaultable(msoSet{i});
        if ~any(eqsFaultable)
            if debug; fprintf('matchValid2: The provided MSO is not susceptible to faults, and faultsOnly flag is true\n'); end
            continue
        end
    end
    
    [new_matchings, new_costs] = matchMSO(gi,msoSet{i}, matchingsPerMSO);
    PSOMatchings = [PSOMatchings new_matchings];
    PSOCosts = [PSOCosts new_costs];
    examination_array(i) = length(msoSet{i}); % Add the size of the current MSO: one examined MJust for each equation in MSO.
    MSOsExamined = MSOsExamined + 1;
    if (MSOsExamined==maxMSOsExamined)
        break;
    end
    % Check if a valid matching has been produced
    if exitAtFirstValid
        gi_blob = getByteStreamFromArray(gi); % Freeze a copy of this PSO
        for m_cell = new_matchings
            matching = m_cell{1};
            if isempty(matching)
                break;
            end
            temp_gi = getArrayFromByteStream(gi_blob); % Restore the PSO
            temp_gi.applyMatching(matching); % Apply the current matching to it

            equIds = temp_gi.getEquations(matching);
            varIds = gi.getVariablesUnknown(equIds);
            if length(varIds)~=length(equIds)
                continue;
            end
            temp_gi.createAdjacency();
            adjacency = temp_gi.adjacency;
            numVars = temp_gi.adjacency.numVars;
            numEqs = temp_gi.adjacency.numEqs;
            validator = Validator(adjacency.BD, adjacency.BD_types, numVars, numEqs);
            offendingEdges = validator.isValid();
            if isempty(offendingEdges)
                % Matching is valid
                valid_matching_found = true;
                break;
            end
        end
        if valid_matching_found
            break;
        end
    end
end
examinations = sum(examination_array);
if debug; fprintf('matchValid2: PSO processed in %d examinations\n',examinations); end

% Sort matchings by cost
[costs_sorted,pivot] = sort(PSOCosts);
M = cell(size(PSOMatchings));
i = 1;
for p = pivot
    M(i) = PSOMatchings(p);
    i = i+1;
end

end


%% Find a valid matching for an MSO
function [MValid, cost] = matchMSO(gi, mso, matchingsPerMSO)
% Loop over available just-constrained submodels

% debug = true;
debug = false;

numEqs = length(mso);

M0weights = ones(1,numEqs)*inf;
M0pool = cell(1,numEqs);

binary_blob = getByteStreamFromArray(gi);

for i=1:numEqs
    
    if debug; fprintf('*** Examining new M0\n'); end
    
    % Choose the equations of the M0 submodel
    equIdsJust = setdiff(mso,mso(i));
    if debug; fprintf('with equation ids: ');  fprintf('%d, ',equIdsJust); fprintf('\n'); end
    aliases = gi.getAliasById(equIdsJust);
    if debug; fprintf('and aliases: ');  fprintf('%s, ',aliases{:}); fprintf('\n'); end
    
    % Create a temporary M0 submodel
%     tempGI = copy(gi);
    tempSG = SubgraphGenerator(gi,binary_blob);
    tempGI = tempSG.buildSubgraph(equIdsJust,'postfix','temp');
    tempGI.createAdjacency();
    
    % Check if all equations can be matched to at least one variable %TODO is this reasonable? What if the whole thing
    % is an AE system?
    A = tempGI.adjacency.E2V;
    if ~all(sum(A,2))
        if debug; warning('Tried to match a non-square system'); end
        Mcurr = [];
    else
        tempMatcher = Matcher(tempGI);
        Mcurr = tempMatcher.match('ValidJust', 'max_num_matchings', matchingsPerMSO);
        % Keep only the cheapest valid matching
        if ~isempty(Mcurr)
            Mcurr = Mcurr(1,:);
        end
    end
    
    % Count matching length
    counter = length(Mcurr);
    
    % TODO: compare weights from all MCurrs
    
    % Check if returned matching is valid and/or complete
    if counter==length(equIdsJust)
        if debug; fprintf('A valid matching for that M0 is (edgeIds): ');  fprintf('%d, ',Mcurr(:)); fprintf('\n'); end
        M0pool(i) = {Mcurr};
        M0weights(i) = sum(gi.getEdgeWeight(Mcurr));
        if debug; fprintf('and cost %d\n',M0weights(i)); end
        
        %             % Select for existence of integral edge
        %             edgeIndices = graph.getIndexById(scc);
        %             foundIntegralEdge = false;
        %             for j=edgeIndices
        %                 if graph.edges(j).isIntegral
        %                     foundIntegralEdge = true;
        %                     fprintf('Found integral edge!\n');
        %                     break;
        %                 end
        %             end
        
    elseif counter>0
        if debug; fprintf('Only partial matching found\n'); end
    else
        if debug; fprintf('No valid matching found\n'); end
    end
        
end

if any(isfinite(M0weights)) %Process matching of this MS0
    % Search for cheapest matching weight
    [cost, pivot] = sort(M0weights);
    i = pivot(1);
    MValid = M0pool(i);
    cost = cost(1);
    
    if debug; fprintf('The selected matching for this MSO is (edgeIds): ');  fprintf('%d, ',MValid); fprintf('\nPlease extend with a residual\n'); end
else
    warning('No valid matching could be found for this MSO\n');
    MValid = [];
    cost = inf;
end

end