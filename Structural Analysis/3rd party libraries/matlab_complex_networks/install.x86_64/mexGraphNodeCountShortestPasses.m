function Neighbours = mexGraphNodeCountShortestPasses(Graph,NodeIDs,Direction)
% At each distance finds all node's neighbours. In fact, gives distribution of shortest passes: provides number of shortest passes per node.
%
% Receives:	
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeIDs		-	vector of indeces	-	(optional) List the ID of the node for whitch the coefficient is computed.
%										If Nodes is an empty matrix, all graph nodes are used. 	Default: []  - result is computed for all nodes.
%	Direction	-	string			-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	Neighbours			-	structure - the structure, containing detailed information about the supplied graph
% 			Field Name							-		Field Type					-	Detailes
%				NodeIDs							-		array	of integers 	- 	Lists IDs of nodes for which the processing was done.
%				Connectivity					-		array of integers		-	For each of the nodes in NodeIDs, holds the number of nodes it is connected to.
%				PassesCount						-		matrix of integers		-	Matrix numel(NodeIDs)x max(Distance), holding number of passes of each distance initiated at each node from NodeIDs.
%				HistogramX						-		array of integers		-	Lists all connectivity values, found in the network. Same as unique(Connectivity)
%				HistogramY						-		array of integers		-	Lists number of nodes having the connectivity of HistogramX. Same as hist(Connectivity,unique(Connectivity)).
%
%
% Example:
%	AllNeighbours = mexGraphNodeCountShortestPasses(WikiGraph{1},[],'direct')
%
% Algorithm:
%	Slightly less efficient then mexGraphNodeConnectivity (you loose ~5% in time. Memory requirements: O(N* MaxShortestPassLength)
%	Scales as O( numel(NodeIDs) ) and as O( N*log( max(ShellSize)), N - number of Nodes in graph. ShellSize(d) - number of nodes at distance d from source node.
%	
%
% See Also:
%	mexNodeNeighbours, mexGraphNodeConnectivity
