clear;
close all;

modelFile;
% kin = [...
%     {'Dnorth phi theta psi u v w'};...
% 	{'Deast phi theta psi u v w'};...
% 	{'Ddown phi theta psi u v w'};
%     {'chi Deast Dnorth'};... % Course angle
%     {'Ddown Deast'};...
% ];
% der = [...
%     {'Dnorth dot north'};...
%     {'Deast dot east'};...
%     {'Ddown dot down'};
% ];
% msr = [...
%     {'msr northm north'};... % GPS measurements
%     {'msr eastm east'};...
%     {'msr downm down'};...
%     {'msr downm2 down'};...
% ];
% constraints = [...
%     {kin},{'k'};...
%     {der},{'d'};...
%     {msr},{'s'};...
%     ];

Graph = modelParser(constraints);
printTable(Graph);
matching = matchingRanking(Graph);
printMatching(Graph,matching);

figure(2);
SM = CreateSM(Graph.adjacency(:,1:132)~=0,[],Graph.adjacency(:,133:end)~=0,Graph.constraints,Graph.unknownVars,{},Graph.knownVars);
% PlotSM(temp);
PlotDM(SM); % Fix it so that variable and constraint names are displayed on screen
dm = GetDMParts(SM); % Perform the Dulmage-Mendelson decomposition

disp('ideal matching size for just- and over-determined parts:');
temp = zeros(1,4);
temp(1) = length(dm.M0vars)+length(dm.Mp.col);
temp(2) = length(Graph.knownVars);
temp(3) = temp(1) + temp(2);
temp(4) = length(dm.M0eqs)+length(dm.Mp.row);
disp(sprintf('%d+%d=%d variables and %d equations',temp));
% 
% temp2 = temp;
% 
% % plotVec = 1:length(dm.Mp.row);
% plotVec = 1:length(dm.Mp.col);
% % plotVec = randperm(length(dm.Mp.row),length(dm.Mp.col));
% 
% temp2.X = temp.X(dm.Mp.row(plotVec),dm.Mp.col);
% temp2.x = temp.x(dm.Mp.col);
% temp2.e = temp.e(dm.Mp.row(plotVec));
% figure()
% PlotDM(temp2)

%% Test Hungarian Method

original = getCalculableSM(SM);
cost = original.X;
cost(cost~=0)=1;
index = cost==0;
cost(index)=inf;

[HMatching, J] = Hungarian(cost);
dm = GetDMParts(original);

figure()
PlotDM(original);
hold on
% spy(HMatching(dm.rowp,dm.colp),'r');
spy(HMatching,'r');
disp(sprintf('Hungarians say that %d matchings have been done',nnz(HMatching)));
temp = HMatching(dm.rowp,dm.colp);
rm = length(dm.Mm.row); cm = length(dm.Mm.col);
rj = length(dm.M0eqs); cj = rj;
rp = length(dm.Mp.row); cp = length(dm.Mp.col);
disp(sprintf('%d of them in the under-constrained graph, out of a total of %d, and', nnz(temp(1:rm,:)), rm ));
disp(sprintf('%d of them in the just-constrained graph, out of a total of %d, and', nnz(temp(rm+1:rm+rj, cm+1:end)) , rj ));
disp(sprintf('%d of them in the over-constrained graph, out of a total of %d', nnz(temp(rm+rj+1:end,cm+cj:end)), cp));