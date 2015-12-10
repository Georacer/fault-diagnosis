function [EmbeddedTiesCount, varargout] = mexGraphCountEmbeddedTies(Graph,NodePairs,Direction)
% Computes the number of common friends between node pairs
%
% Receives:	
%	Graph		-	Graph Struct			-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodePairs	-	vector of nodes, 2xM    -	A list of M node pairs. The number of common neighbors is computed for each pair. May be signed integer of 8,16,32 or 64 bits or double. 
%	Direction	-	string					-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%												followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	EmbeddedTiesCount -	vector of integer values, 1xM  -	number of common friends for each node
%	NodePairs		  - 	vector of indeces, 2xM  - (optional)list of node pairs for which he function was called. 
%
%
% Algorithm:
%       http://www.analytictech.com/ucinet/help/hs4387.htm
%
% Notes:
%	The mothod is optimized for the input where NodePairs represents a substantial part of the graph. In particular, the internal representation of the graph sorts nodes to accelerate 
%	the test for overlap in friends. In that case, the size of the overlap in friends between nodes i & j is computed in Ki+Kj rather than min(Ki,Kj)*log(max(Ki,Kj)) where Ki is the number 
%	i's neighbours. The drawback of the method is that it requires sorting peer ids of every node: sum(Ki*log(Ki),i).  This is only worth for the cases when the set of NodePiars covers most of the graph. 
%	For optimal performance, the user should try and execute this method least possible times with largest possible NodePairs set. 
%   The test.m commented out code (below) tests the method (assuming this function is renamed to mexGraphCountEmbeddedTies.m) and find that it is typically 30-40 times slower than the mex-file. 
%
% See Also:
%	ObjectCreateGraph , GraphLoad
%																						

%% !!!! The following implementation is inefficient and incomplete and is only helpful to test the mex-file
%% testing code:
%{
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
Result1 = mexGraphCountEmbeddedTies1(Graph, Graph.Data(LinkIndeces,1:2));
toc
if any(Result ~=Result1), error('FAILED!!!!'); 
else disp('passed the test'); end
%}


if exist('Direction','var')
    switch lower(Direction)
        case 'direct' 
             
        case 'inverse'
            Graph.Data = Graph.Data(:,[2 1 3]);
        case 'both'
            Graph = GraphMakeUndirected(Graph);
    end
end
EmbeddedTiesCount  =zeros(size(NodePairs,1),1);
UniqueNodeIDs = unique(NodePairs(:));
Neighbours =  mexNodeNeighbours(Graph,UniqueNodeIDs,1,'direct');

for i = 1 : size(NodePairs,1)
     EmbeddedTiesCount(i) = numel(intersect( Neighbours{ UniqueNodeIDs==NodePairs(i,1)},Neighbours{ UniqueNodeIDs==NodePairs(i,2)}));
end
if nargout>1 , varargout{1} = NodePairs; end