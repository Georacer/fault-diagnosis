%% A standard structural analysis workflow1
close all;
clear all;
clc;

% profile on
times = {};

%% Create the initial graph
tic

% mygraph = createGraph('random',[10 9]);
mygraph = createGraph('g018');

graph.causality = 'Mixed'; % Set causality first in order to avoid requests for evaluations of non-invertible edges

t = toc;
times{end+1} = {'Initial graph creation',t};
fprintf('Graph creation lasted %g secs\n',t);
% return

%% Verify Graph
% Investigate the graph attributes
% cyclic = mygraph.hasCycles();
% if cyclic
%     disp('The system graph is cyclic');
% else
%     disp('The system graph is not cyclic');
% end

% return

%% Plot the graph
tic

plotModel(mygraph,1,'initial');

t = toc;
times{end+1} = {'Initial graph plotting',t};
fprintf('Graph visualization lasted %g secs\n',t);
% return

%% Get over-constrained part
tic

graphOver = mygraph.getOver();
% Create the incidence matrix
graphOver.createAdjacency();

% Create Linkopping University structural model
graphOver.createLiusm();
graphOver.liusm.Lint();

t = toc;
times{end+1} = {'Overconstrained graph creation',t};
fprintf('Isolating overconstrained part lasted %g secs\n',t);
% return

%% Plot the graph
tic

plotModel(mygraph,1,'overconstrained');

t = toc;
times{end+1} = {'Overconstrained graph plotting',t};
fprintf('Overconstrained graph plotting lasted %g secs\n',t);
% return

%% Perform preliminary matchings (non-looping)
tic

% Select causality
mygraph.causality = 'Differential'; % None, Integral, Differential, Mixed, Realistic

% graphOver.matchRanking();
graphOver.matchWeightedElimination('maxRank',0);

graphUndir = graphOver.copy(); % This is what remains unmatched

% Investigate residual signatures
fprintf('Building residual signature array:\n');
[signatures, generator_id] = graphOver.getResidualSignatures();

t = toc;
times{end+1} = {'Loopless matchings',t};
fprintf('Loopless matching lasted %g secs\n',t);
% return

%% Find MTESs and select MSOs
tic

graphMTES = graphOver.copy();

% Delete matched equations
graphMTES.deleteEquation(graphMTES.getEquIdByProperty('isMatched'));

% Create the incidence matrix
graphMTES.createAdjacency();

% Create Linkopping University structural model
graphMTES.createLiusm();
graphMTES.liusm.Lint();

% EITHER %
% Find MSOs involving faults
faultIndArray = find(sum(graphMTES.liusm.F,2))';
graphMTES.liusm.CompiledMSO();
MSOs = graphMTES.liusm.MSO();
MTESs = cell(0,0);
for i=1:length(MSOs)
    if any(ismember(MSOs{i},faultIndArray));
        MTESs(end+1) = MSOs(i);
    end
end

% OR %
% MTESs = graphMTES.liusm.MTES();

t = toc;
times{end+1} = {'Finding MSOs/MTESs',t};
fprintf('Finding MSOs/MTESs lasted %g secs\n',t);
% return

%% Loop over available MSOs to find valid residual generators
tic

% Select causality
graphMTES.causality = 'Realistic'; % None, Integral, Differential, Mixed, Realistic

Mvalid = extractResiduals(graphMTES,MTESs);

if ~exist('Mvalid')
    load Mvalid
end

% Verify candidate residual generators
validMatchings = zeros(1,length(Mvalid));
for i = 1:length(Mvalid)
    validMatchings(i) = graphMTES.validateMatching(Mvalid{i}{2:end});
end

t = toc;
times{end+1} = {'Extracting valid residual generators',t};
fprintf('Extracting valid residual generators lasted %g secs\n',t);
% return

%% Check if different MSOs match the same equation in different ways
% In general they do
% clc
%
% equationList = zeros(graphMTES.numEqs, graphMTES.numVars);
% for i=1:length(Mvalid)
%     KHcomp = Mvalid{i}(2:end);
%     for j=1:length(KHcomp)
%         scc = KHcomp{j};
%         for k=1:length(scc)
%             mi = scc(k);
%             mi_index= graphMTES.getIndexById(mi);
%             equId = graphMTES.edges(mi_index).equId;
%             varId = graphMTES.edges(mi_index).varId;
%             equIndex = graphMTES.getIndexById(equId);
%             varIndex = graphMTES.getIndexById(varId);
%             equationList(equIndex,varIndex) = 1;
%         end
%     end
% end

%% Build fault signatures, detectability and isolability specification
tic
% Generate the fault signature of each residual generator for the initial G+ graph

[signatures2, FSM] = generateSignatures(graphMTES,graphOver, graphUndir, Mvalid, signatures, generator_id);

resSelected = 1:length(signatures2);

fh = plotFSM(graphOver, FSM);
% Plot detectability matrix

fh = plotIM(graphOver, FSM);

faultIds = graphOver.getEquIdByProperty('isFaultable');
faultIndices = graphOver.getIndexById(faultIds);
fprintf('Detectable fault for equations\n');
for i=1:length(faultIndices)
fprintf('%s/%d: %s\n',graphOver.equationAliasArray{faultIndices(i)},graphOver.equationIdArray(faultIndices(i)),graphOver.equations(faultIndices(i)).expressionStructural)
end

fprintf('Residuals detecting each fault\n');
for i=1:length(faultIndices)
fprintf('%d: ',i); fprintf('%d,\t',find(FSM(:,i))); fprintf('\n');
end

t = toc;
times{end+1} = {'Building fault signatures, detectability and isolability',t};
fprintf('Building fault signatures, detectability and isolability lasted %g secs\n',t);
% return

%% Decide upon matchings based on detectability and isolability
% tic
% 
% t = toc;
% times{end+1} = {'Selecting residuals based in isolability criteria',t};
% fprintf('Selecting residuals based in isolability criteria lasted %g secs\n',t);
% return

%% Print matching of selected residuals
% resSelected = 8;
% for i=resSelected
%     
%     generatorId = signatures2{i,1};
%     matching = signatures2{i,4};
%     
%     fprintf('Residual from %s with ID %d:\n',graphOver.getAliasById(generatorId),generatorId);
%     graphOver.printEdges(matching);
% end

% return

%% Cleanup routines

% profile viewer
% profile off