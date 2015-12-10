% KCCTest01
N = 3000; k = 4; p=k/(N-1); Graph = mexGraphGeneratePoissonRandomGraph(N,p);
% load('D:\Network.mat');
tic
KCC = mexGraphLinkDirectionality(Graph);
toc
CC=mexGraphClusteringCoefficient(Graph);
for i = 1 : numel(KCC.KCCData)
    if (KCC.KCCData{i}(2).LinksAt~=CC.NodeNeighboursLinks(i))
        error(num2str(i));
    end
end
for i = 1 : numel(KCC.KCCDataAverage)
%     KCC.KCCDataAverage(i).R
end
% 11 : 
% 28        251
% 112       11, 219, 230
% 278       38    49    72   119   163   166   182   267

%{
1 : 
   16         12    17    56   225   264
   105        163   225   226   248   276
   153          14    19   133   259   282

%}