%% A standard structural analysis workflow1
close all;
clear all;
clc;

% profile on

%% Create graph

% Select a model file to create the cell structure
% [model, coords] = randomGraph(8,5);
% [model, name, coords] = g001();
% [model, coords] = g002();
% [model, coords] = g003();
% [model, coords] = g004();
% [model, name, coords] = g005();
% [model, coords] = g006();
% [model, name, coords] = g007();
% [model, name, coords] = g007a();
% [model, coords] = g008();
% [model, name, coords] = g009a();
% [model, name, coords] = g010();
% [model, name, coords] = g011();
% [model, name, coords] = g012();
% [model, name, coords] = g013();
[model, name, coords] = g014(); if exist('g014_costlist.mat') load g014_costlist.mat; end

% Create the graph object
mygraph = GraphBipartite(model,name,coords);
disp('Built graph object');

if ~exist('costList')
    disp('No cost list found in the workspace, creating a default one');
    costList = mygraph.createCostList(true);
end

mygraph.readCostList(costList);

% return

%% Select causality
mygraph.causality = 'Mixed'; % None, Integral, Differential, Mixed, Realistic

%% Create the incidence matrix
mygraph.createAdjacency();

%% Create Linkopping University structural model
mygraph.createLiusm();
mygraph.liusm.Lint();

%% Plot the created graph
% Display the adjacency matrices
% figure();
% mygraph.plotSparse()
%
% figure();
% mygraph.liusm.PlotModel();
% set(gca,'YTickLabel',mygraph.equationAliasArray);
%
% figure();
% mygraph.plotDM();



% % Display the graph using Graphviz4Matlab
% mygraph.plotG4M();
% if (isempty(coords))
%     coords = mygraph.coords;
% end
%
% % Let the use re-arrange the nodes
% disp('Rearrange node positions if needed and press ENTER');
% pause();
% coords = mygraph.ph.getNodePositions();
% mygraph.coords = coords;

% Display the graph using external dot compiler
% mygraph.plotDot();

% return

%% Verify Graph
% % Investigate the graph attributes
% cyclic = mygraph.hasCycles();
% if cyclic
%     disp('The system graph is cyclic');
% else
%     disp('The system graph is not cyclic');
% end
%
% % return

%% Get over-constrained part

graphOver = mygraph.getOver();
% Create the incidence matrix
graphOver.createAdjacency();

% Create Linkopping University structural model
graphOver.createLiusm();
graphOver.liusm.Lint();

% Plot the created graph
% Display the adjacency matrices
% figure();
% graphOver.plotSparse()
%
% figure();
% graphOver.liusm.PlotModel();
% set(gca,'YTickLabel',graphOver.equationAliasArray);
%
% figure();
% graphOver.plotDM();

%% Select causality
mygraph.causality = 'Differential'; % None, Integral, Differential, Mixed, Realistic

%% Perform matching
% profile on

% graphOver.matchRanking();
graphOver.matchWeightedElimination();

graphUndir = graphOver.copy();

% profile viewer
% profile off

%% Investigate residual signatures
fprintf('Building residual signature array:\n');
[signatures, generator_id] = graphOver.getResidualSignatures();

%% Select causality
graphOver.causality = 'Realistic'; % None, Integral, Differential, Mixed, Realistic

%% Create new, resulting graph
graphMTES = graphOver.copy();

% Delete matched equations
graphMTES.deleteEquation(graphMTES.getEquIdByProperty('isMatched'));

% Create the incidence matrix
graphMTES.createAdjacency();

% Create Linkopping University structural model
graphMTES.createLiusm();
graphMTES.liusm.Lint();
% Plot the created graph
% Display the adjacency matrices
% figure();
% graphMTES.plotSparse()

figure();
graphMTES.liusm.PlotModel();
set(gca,'YTickLabel',graphMTES.equationAliasArray);

figure();
graphMTES.plotDM();

%% Find MSOs involving faults

faultIndArray = find(sum(graphMTES.liusm.F,2))';
MSOs = graphMTES.liusm.MSO();
MTESs = cell(0,0);
for i=1:length(MSOs)
    if any(ismember(MSOs{i},faultIndArray));
        MTESs(end+1) = MSOs(i);
    end
end

%% Loop over available MSOs
clc

% Initialize valid matchings container
Mvalid = {};

h = waitbar(0,'Processed MSOs');

for indexMTES = 1:length(MTESs)

    waitbar(indexMTES/length(MTESs),h,sprintf('Found %d residual generators',length(Mvalid)));
    fprintf('*** Examining MSO %d\n',indexMTES);
    MSOcurr = MTESs{indexMTES};

    % Loop over available just-constrained submodels
    M0weights = ones(1,length(MSOcurr))*inf;
    M0pool = cell(1,length(MSOcurr));
    for i=1:length(MSOcurr)

        fprintf('*** Examining new M0\n');
        SMjust = MSOcurr(setdiff(1:length(MSOcurr),i));
        SMjustIds = graphMTES.equationIdArray(SMjust);

        % Find a valid matching for that M0
        Mcurr = graphMTES.matchValid(SMjustIds);
        
        % TODO: compare weights from all MCurrs
        if ~isempty(Mcurr)
            M0pool(i) = {Mcurr};
            KHcomp = Mcurr(:);
            scc = [];
            for j=1:length(KHcomp)
                scc = [scc KHcomp{j}];
            end
            M0weights(i) = sum(graphMTES.getEdgeWeight(scc));
        end
    end
    [~, pivot] = sort(M0weights);
    i = pivot(1);
    Mvalid(end+1) = {[MSOcurr(i) M0pool(i)]};
end

close(h)

if ~exist('Mvalid')
    load Mvalid
end

%% Validate matching results
validMatchings = zeros(1,length(Mvalid));
for i = 1:length(Mvalid)
    validMatchings(i) = graphMTES.validateMatching(Mvalid{i}{2:end});
end

%% Check if different MSOs match the same equation is different ways
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

%% Generate the fault signature of each residual generator for the initial G+ graph

% clc

MvalidFlat = cell(size(Mvalid));
for i=1:length(Mvalid)
    MvalidFlat{i}{1} = graphMTES.equationIdArray(Mvalid{i}{1});
    KHcomp = Mvalid{i}{2:end};
    scc = [];
    for j=1:length(KHcomp)
        scc = [scc KHcomp{j}];
    end
    MvalidFlat{i}{2} = scc;
end

signatures2 = cell(length(Mvalid)+length(generator_id),4); % Matching weight is the 3rd column, matching is 4th column

for i=1:size(signatures,1)
    affectingEqs = graphOver.equationIdArray(logical(signatures(i,:)));
    signatures2(i,1) = {generator_id(i)};
    signatures2(i,2) = {affectingEqs};
    matchingEqs = setdiff(affectingEqs,generator_id(i));
    eqIndices = graphOver.getIndexById(matchingEqs);
    matching = [];
    matchingWeight = 1; % Initial residual evaluation cost
    for j=1:length(eqIndices)
        varId = graphOver.equations(eqIndices(j)).matchedTo;
        edgeId = graphOver.getEdgeIdByVertices(matchingEqs(j),varId);
        matching(end+1) = edgeId;
        matchingWeight = matchingWeight + graphOver.getEdgeWeight(edgeId);
    end
    signatures2(i,3) = {matchingWeight};
    signatures2(i,4) = {matching};
end

for i=1:length(Mvalid)
    clear graphNew
    graphNew = graphUndir.copy();
    graphNew.applyMatching(MvalidFlat{i}{2});
    resGenId = MvalidFlat{i}{1};
    [affectingEqs, matching] = graphNew.getAncestorEqs(resGenId);
    affectingEqs = [resGenId affectingEqs];
    signatures2{i+length(generator_id),1} = resGenId;
    signatures2{i+length(generator_id),2} = affectingEqs;
    matchingWeight = sum(graphOver.getEdgeWeight(matching)) + 1;
%     matchingWeight = sum(graphOver.getEdgeWeight(MvalidFlat{i}{2})) + 1;
    signatures2{i+length(generator_id),3} = matchingWeight;
    signatures2{i+length(generator_id),4} = matching;
end

%% Convert to proper signature table

% clc
% 
% FSM = zeros(size(signatures2,1),graphOver.numEqs);
% 
% for i=1:size(FSM,1)
%     FSM(i,graphOver.equationIdToIndexArray(signatures2{i,2}))=1;
% end
% 
% % Reduce FSM columns to only faultable equations
% faultIds = graphOver.getEquIdByProperty('isFaultable');
% faultIndices = graphOver.getIndexById(faultIds);
% FSM = FSM(:,faultIndices);
% IM = isolabilityMatrix(FSM);

%% Decide upon matchings based on detectability and isolability

clc

resWeights = zeros(1,size(signatures2,1));

for i=1:length(resWeights)
    resWeights(i) = signatures2{i,3};
end

[~,pivot] = sort(resWeights);

FSM = zeros(0,graphOver.numEqs);
FSMstar = [];
resSelected = [];
numDetections = 0;

% Build for max detectability
for i=1:length(pivot)
    newline = zeros(1,size(FSM,2));
    newline(graphOver.equationIdToIndexArray(signatures2{pivot(i),2}))=1;
    FSMstar = [FSM; newline];
    NDstar = nnz(sum(FSMstar,1));
    if NDstar > numDetections
        numDetections = NDstar;
        FSM = FSMstar;
        resSelected(end+1) = pivot(i);
    end    
end

% Print selected residuals
fprintf('Building MSO generator lookup table\n');
MSOGenerators = zeros(1,size(MvalidFlat,2));
for j=1:length(MSOGenerators)
    MSOGenerators(j)=MvalidFlat{j}{1};
end
fprintf('Building ranking generator lookup table\n');
overGenerators = graphOver.getEquIdByProperty('isResGenerator'); % For matching information on initial generators
fprintf('Iterating over generators\n');
for i=resSelected
    
    generatorId = signatures2{i,1};
    matching = signatures2{i,4};
    
%     
%     
%     if i<=length(generator_id) % This is an elimination generator
%         fprintf('Found a ranking generator\n');
%         equIds = signatures2{resSelected(i),2};
%         equIndices = graphOver.getIndexById(equIds);
%         varIds = zeros(size(equIds));
%         edgeIds = zeros(size(equIds));
%         for j=1:length(varIds)
%             matchedVarId = graphOver.equations(equIndices(j)).matchedTo;
%             if ~isempty(matchedVarId)
%                 varIds(j) = matchedVarId;
%                 edgeIds(j) = graphOver.getEdgeIdByVertices(equIds(j),varIds(j));
%             else
%                 edgeIds(j) = graphOver.equations(equIndices(j)).edgeIdArray(end);
%             end
%         end
%         
%     else % This is an MSO generator
%         fprintf('Found an MSO generator\n');
%         edgeIds = MvalidFlat{i-length(generator_id)}{2};
%     end
    
    fprintf('Residual from %s with ID %d:\n',graphOver.getAliasById(generatorId),generatorId);
    graphOver.printEdges(matching);
end

% return

%% Display mathcing and calculation order
% mygraph.plotMatching();
graphOver.plotMatching2();

%% Cleanup routines

% profile viewer
% profile off