% test
NumberOfNodes = 3000; % Number of nodes
Alpha = -2;   % Alpha of the scale-free graph
%define node degree distribution:
XAxis  = unique(round(logspace(0,log10(NumberOfNodes),25)));
YAxis  = unique(round(logspace(0,log10(NumberOfNodes),25))).^(Alpha+1);
% create the graph with the required node degree distribution:
% Graph = GraphCreateRandomGraph(NumberOfNodes,XAxis,YAxis,1);
Graph = mexGraphGeneratePoissonRandomGraph(NumberOfNodes,0.05);

FractionOfSampledLinks = 0.1;
LinkIndeces = randsample(GraphCountNumberOfLinks(Graph), round(GraphCountNumberOfLinks(Graph)*FractionOfSampledLinks));
tic
Result = mexGraphCountEmbeddedTies(Graph, Graph.Data(LinkIndeces,1:2));
toc
tic
Result1 = mexGraphCountEmbeddedTies(Graph, Graph.Data(LinkIndeces,1:2));
toc
if any(Result ~=Result1), error('FAILED!!!!'); 
else disp('passed the test'); end