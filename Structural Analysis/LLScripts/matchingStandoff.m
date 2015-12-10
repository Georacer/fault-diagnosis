%% A comparative test between different matching methodologies

clear;
close all;

benchmark; % Load the model file

Graph = modelParser(constraints);
printTable(Graph);

%% Classic DM

AV = Graph.adjacency(:,1:length(Graph.unknownVars));
AI = Graph.adjacency(:,1:length(Graph.unknownVars)+1:end);
SM = CreateSM(AV,[],AI,Graph.constraints,Graph.unknownVars,{},Graph.knownVars);
% figure(2);
% PlotSM(temp);
% PlotDM(SM); % Fix it so that variable and constraint names are displayed on screen
dm = GetDMParts(SM); % Perform the Dulmage-Mendelson decomposition

disp('ideal matching size for just- and over-determined parts:');
temp = zeros(1,4);
temp(1) = length(dm.M0vars)+length(dm.Mp.col);
temp(2) = length(Graph.knownVars);
temp(3) = temp(1) + temp(2);
temp(4) = length(dm.M0eqs)+length(dm.Mp.row);
disp(sprintf('%d+%d=%d variables and %d equations',temp));

%% Ranking

matching = matchingRanking(Graph);
printMatching(Graph,matching);

%% Hungarian Method

original = getCalculableSM(SM);
dm = GetDMParts(original);

causality = [49];
% causality = [49 68];
cost = HungarianCost(original.X, causality);

[HMatching, J] = Hungarian(cost);

figure()
PlotDM(original);
hold on
spy(HMatching(dm.rowp,dm.colp),'r');
% spy(HMatching,'r');
disp(sprintf('Hungarians say that %d matchings have been done',nnz(HMatching)));
temp = HMatching(dm.rowp,dm.colp);
rm = length(dm.Mm.row); cm = length(dm.Mm.col);
rj = length(dm.M0eqs); cj = rj;
rp = length(dm.Mp.row); cp = length(dm.Mp.col);
disp(sprintf('%d of them in the under-constrained graph, out of a total of %d, and', nnz(temp(1:rm,:)), rm ));
disp(sprintf('%d of them in the just-constrained graph, out of a total of %d, and', nnz(temp(rm+1:rm+rj, cm+1:end)) , rj ));
disp(sprintf('%d of them in the over-constrained graph, out of a total of %d', nnz(temp(rm+rj+1:end,cm+cj:end)), cp));