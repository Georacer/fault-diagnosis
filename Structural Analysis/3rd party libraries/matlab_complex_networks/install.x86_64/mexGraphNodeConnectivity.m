function AllNeighbours = mexGraphNodeConnectivity(Graph,NodeIDs,Direction)
% Finds all nodes which can be reached from each of the NodeIDs. The source node is never included.
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
%	AllNeighbours			-	structure - the structure, containing detailed information about the supplied graph
% 			Field Name							-		Field Type					-	Detailes
%				NodeIDs							-		array	of integers 	- 	Lists IDs of nodes for which the processing was done.
%				Connectivity					-		array of integers		-	For each of the nodes in NodeIDs, holds the number of nodes it is connected to.
%				HistogramX						-		array of integers		-	Lists all connectivity values, found in the network. Same as unique(Connectivity)
%				HistogramY						-		array of integers		-	Lists number of nodes having the connectivity of HistogramX. Same as hist(Connectivity,unique(Connectivity)).
%
%
% Example:
%	AllNeighbours = mexGraphNodeConnectivity(WikiGraph{1},[],'direct')
%
% Algorithm:
%	Scales as O( numel(NodeIDs) ) and as O( N*log( max(ShellSize)), N - number of Nodes in graph. ShellSize(d) - number of nodes at distance d from source node.
%
% See Also:
%	mexNodeNeighbours
%																										
