function M = MixedMatching( mh, varargin )
%WEIGHTEDELIMINATION Mixed causality matching, from Svard2010
% C. Svard and M. Nyberg, “Residual Generators for Fault Diagnosis Using Computation Sequences With Mixed Causality
% Applied to Automotive Systems,” IEEE Transactions on Systems, Man, and Cybernetics - Part A: Systems and Humans, 
% vol. 40, no. 6, pp. 1310–1328, Nov. 2010.


p = inputParser;

p.addRequired('mh',@(x) true);
p.addParameter('faultsOnly',true, @islogical);
p.addParameter('maxMSOsExamined', 0, @isnumeric);
p.addParameter('exitAtFirstValid', true, @islogical);

p.parse(mh, varargin{:});
opts = p.Results;

faultsOnly = opts.faultsOnly; % Generate only residuals which are sensitive to faults
maxMSOsExamined = opts.maxMSOsExamined;
exitAtFirstValid = opts.exitAtFirstValid;

debug = true;
% debug = false;

% Edge types
DEF_INT = 2;
DEF_DER = 3;
DEF_NI = 4;
DEF_AE = 5;

gi = mh.gi;
% Initialize valid matchings container
M = [];

eqsFaultable = gi.getEquIdByProperty('isFaultable');
if (faultsOnly && isempty(eqsFaultable))
    if debug; fprintf('Mixed: The provided PSO is not susceptible to faults, and faultsOnly flag is true\n'); end
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

% Sort the msos in order of sise
mso_size = zeros(1,length(msoSet));
for i=1:length(mso_size)
    mso_size(i) = length(msoSet{i});
end    
[~,pivot] = sort(mso_size);
old_msoSet = msoSet;
i = 1;
for p = pivot
    msoSet(i) = old_msoSet(p);
    i = i+1;
end

% Loop over the collected MSOs
PSOCosts = inf*ones(1,0);
PSOMatchings = cell(1,0);
MSOsExamined = 0;
examination_array = zeros(1,length(msoSet)); % How many residual generators have been examined
valid_matching_found = false;
for i=1:length(msoSet)
    if debug; fprintf('Mixed: Testing MSO %d/%d with size %d\n',i,length(msoSet),length(msoSet{i})); end
    
    % Test for faultable equations
    if faultsOnly
        eqsFaultable = gi.isFaultable(msoSet{i});
        if ~any(eqsFaultable)
            if debug; fprintf('Mixed: The provided MSO is not susceptible to faults, and faultsOnly flag is true\n'); end
            continue
        end
    end
    
    [new_matchings, new_costs] = matchMSO(gi,msoSet{i});
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
if debug; fprintf('Mixed: PSO processed in %d examinations\n',examinations); end

% Sort matchings by cost
[costs_sorted,pivot] = sort(PSOCosts);
M = cell(size(PSOMatchings));
i = 1;
for p = pivot
    M(i) = PSOMatchings(p);
    i = i+1;
end

end

%% Find all matchings for an MSO
function [M0pool, M0weights] = matchMSO(gi, mso)
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
    tempSG = SubgraphGenerator(gi,binary_blob);
    tempGI = tempSG.buildSubgraph(equIdsJust,'postfix','temp');
    tempGI.createAdjacency();
    

    % Check if the passed system is square
    var_ids = tempGI.getVariablesUnknown();
    num_vars = length(var_ids);
    num_equs = length(unique(tempGI.getEquations(var_ids)));
    if ~(num_vars == num_equs)
        error('Tried to match a non-square system');
    else
        Mcurr = findCalculationSequence(tempGI);
    end
    
    % Count matching length
    counter = length(Mcurr);
    
    % Check if returned matching is valid and/or complete
    if counter==length(equIdsJust)
        if debug; fprintf('A valid matching for that M0 is (edgeIds): ');  fprintf('%d, ',Mcurr(:)); fprintf('\n'); end
        M0pool(i) = {Mcurr};
        M0weights(i) = sum(gi.getEdgeWeight(Mcurr));
        if debug; fprintf('and cost %d\n',M0weights(i)); end
    elseif counter>0
        if debug; fprintf('Only partial matching found\n'); end
    else
        if debug; fprintf('No valid matching found\n'); end
    end
        
end

if ~any(isfinite(M0weights)) %Process matching of this MS0
    warning('No valid matching could be found for this MSO\n');
end

end

function M = findCalculationSequence(gi)
    % Implementation of the FindCalculationSequence pseudoalgorithm
    gi.createAdjacency();
    E2V = gi.adjacency.V2E';
    var_ids = gi.reg.varIdArray;
    equ_ids = gi.reg.equIdArray;
    all_ids = [gi.reg.varIdArray gi.reg.equIdArray];
    num_vars = gi.graph.numVars;
    num_eqs = gi.graph.numEqs;
    
    M = [];
    
    KH_list = getKHComps( gi, E2V, equ_ids, var_ids );
    
    for i=1:length(KH_list)
        KH = KH_list{i};
        KH_var_ids = KH.varIds;
        KH_equ_ids = KH.equIds;
        edge_ids = KH.edgegroup;
        
        % Find all integral (state) variables
        integ_mask = gi.isIntegral(edge_ids);
        integ_edge_ids = edge_ids(logical(integ_mask));
        if ~isempty(integ_edge_ids)
            integ_var_ids = gi.getVariables(integ_edge_ids);
        else
            integ_var_ids = [];
        end
        
        % Find all differentiated variables
        deriv_mask = gi.isDerivative(edge_ids);
        deriv_edge_ids = edge_ids(logical(deriv_mask));
        if ~isempty(deriv_edge_ids)
            deriv_var_ids = gi.getVariables(deriv_edge_ids); % Z set
        else
            deriv_var_ids = [];
        end
        
        % Check if this is a top-level explicit differentiation of size 1
        % If yes, match in in differential causality
        if length(KH_equ_ids)==1 && length(deriv_var_ids)==1
            M = [M KH.edgegroup];
            continue
        end
        
        % Find all algebraic variables
        algeb_var_ids = setdiff(KH_var_ids,[integ_var_ids, deriv_var_ids]); % W set
        
        % Find the set of equations with derivative variables
        temp = intersect(KH_equ_ids, gi.getEquations(deriv_var_ids));
        all_dynamic_equ_ids = gi.getEquIdByProperty('isDynamic');
        explicit_diffs = intersect(KH_equ_ids, all_dynamic_equ_ids);
        dynamic_equ_ids = setdiff(temp,explicit_diffs); % Ez
        
        % Find the algebraic equations
        algeb_equ_ids = setdiff(KH_equ_ids, [explicit_diffs dynamic_equ_ids]); % Ew
        
        % Find all dynamic SCCs
        equ_idx_array = ismember(equ_ids, dynamic_equ_ids);
        var_idx_array = ismember(var_ids, deriv_var_ids);
        KH_list_dynamic = getKHComps( gi, E2V(equ_idx_array, var_idx_array), dynamic_equ_ids, deriv_var_ids);
        
        % Assign dynamic equations to their differentiated variable
        for j=1:length(KH_list_dynamic)
            KH_dynamic = KH_list_dynamic{j};
            % Assert that all KH components are singular
            if (length(KH_dynamic.equIds)~=1)
                error('Something went wrong');
            end
            if (length(KH_dynamic.varIds)~=1)
                error('Something went wrong');
            end
            if (length(KH_dynamic.edgegroup)~=1)
                error('Something went wrong');
            end
            M = [M KH_dynamic.edgegroup];
        end
        
        % Assign explicit differentiations to their integral variable
        M = [M integ_edge_ids];
        
        % Find all algebraic SCCs
        equ_idx_array = ismember(equ_ids, algeb_equ_ids);
        var_idx_array = ismember(var_ids, algeb_var_ids);
        KH_list_algebraic = getKHComps( gi, E2V(equ_idx_array, var_idx_array), algeb_equ_ids, algeb_var_ids);
        
        % Assert that the algebraic substystem is square
        if (length(algeb_equ_ids)~=length(algeb_var_ids))
            error('Algebraic part not square');
        end
        
        for j=1:length(KH_list_algebraic)
            KH_algeb = KH_list_algebraic{j};
            M = [M gi.getEdgeIdByVertices(KH_algeb.equIds, KH_algeb.varIds)];
        end
        
    end

end