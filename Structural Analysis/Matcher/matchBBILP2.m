function [ M ] = matchBBILP2( matcher, varargin )
%MATCHVALID Find valid residuals in provided MTES
%   Uses Branch-and-Bound Integer Linear Programming
%   Breaks the passed PSO down to MSOs

% debug = false;
debug = true;

if debug
    if ~evalin('base','exist(''examinations'')')
        evalin('base','examinations=0');
    end
end

p = inputParser;

p.addRequired('matcher',@(x) true);
p.addParameter('branchMethod','cheap',@isstr);
p.addParameter('maxMSOsExamined', 0, @isnumeric);
p.addParameter('faultsOnly',true, @islogical);
p.addParameter('exitAtFirstValid', false, @islogical);
p.addParameter('maxSearchTime', inf, @isnumeric);

p.parse(matcher, varargin{:});
opts = p.Results;
branchMethod = opts.branchMethod;
maxMSOsExamined = opts.maxMSOsExamined;
faultsOnly = opts.faultsOnly; % Generate only residuals which are sensitive to faults
exitAtFirstValid = opts.exitAtFirstValid;
maxSearchTime = opts.maxSearchTime;

gi = matcher.gi;

M = [];

eqsFaultable = gi.getEquIdByProperty('isFaultable');
if (faultsOnly && isempty(eqsFaultable))
    if debug; fprintf('BBILP2: The provided PSO is not susceptible to faults, and faultsOnly flag is true\n'); end
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
MSOsExamined = 0;
PSOCosts = inf*ones(1,0);
PSOMatchings = cell(1,0);
examination_array = zeros(1,length(msoSet));

for i=1:length(msoSet)
    if debug; fprintf('BBILP2: Testing MSO %d/%d with size %d\n',i,length(msoSet),length(msoSet{i})); end
    
    % Test for faultable equations
    if faultsOnly
        eqsFaultable = gi.isFaultable(msoSet{i});
        if ~any(eqsFaultable)
            if debug; fprintf('BBILP2: The provided MSO is not susceptible to faults, and faultsOnly flag is true\n'); end
            continue
        end
    end
    
    [new_matching, new_cost] = matchMSO(gi,msoSet{i}, branchMethod);
    if ~isempty(new_matching)
        PSOMatchings = [PSOMatchings new_matching];
        PSOCosts = [PSOCosts new_cost];
    end
    examination_array(i) = length(msoSet{i}); % Add the size of the current MSO: one examined MJust for each equation in MSO.
    MSOsExamined = MSOsExamined + 1;
    if (MSOsExamined==maxMSOsExamined)
        break;
    end
    % Check if a valid matching has been produced
    if exitAtFirstValid
        if ~isempty(new_matching)
            break;
        end
    end
end
examinations = sum(examination_array);
if debug; fprintf('BBILP2: PSO processed in %d examinations\n',examinations); end

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
function [MValid, cost] = matchMSO(gi, mso, branchMethod)
% Loop over available just-constrained submodels

% debug = true;
debug = false;

tempSG = SubgraphGenerator(gi);
tempGI = tempSG.buildSubgraph(mso,'postfix','temp');
tempGI.createAdjacency();

tempMatcher = Matcher(tempGI);
MValid = tempMatcher.match('BBILP','branchMethod',branchMethod,'maxSearchTime',maxSearchTime);
if ~isempty(MValid)
    cost = sum(tempGI.getEdgeWeight(MValid));
else
    cost = inf;
end

end
