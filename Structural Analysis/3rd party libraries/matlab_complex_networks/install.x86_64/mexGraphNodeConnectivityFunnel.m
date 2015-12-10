function AllNeighbours = mexGraphNodeConnectivityFunnel(Graph,NodeIDs,Direction)
% Counts number of nodes at each distance from the source node
%
% Receives:	
%	Graph		-	Graph Struct			-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeID		-	array of Node indece   	-	(optional) IDs of a source nodes. Default  - [] (all)
%	Direction	-	string					-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%												followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	AllNeighbours			-	structure - the structure, containing detailed information about the supplied graph
% 			Field Name							-		Field Type					-	Detailes
%				NodeIDs							-		array	of integers 	- 	Lists IDs of nodes for which the processing was done.
%				Connectivity					-		array of integers		-	For each of the nodes in NodeIDs, holds the number of nodes it is connected to.
%				ConnectivityFinnel				-		cell array				-	For each node, a list of nummber of it's neighbours at each distance is listed.
%				HistogramX						-		array of integers		-	Lists all connectivity values, found in the network. Same as unique(Connectivity)
%				HistogramY						-		array of integers		-	Lists number of nodes having the connectivity of HistogramX. Same as hist(Connectivity,unique(Connectivity)).
%
%
% Example:
%	AllNeighbours = mexGraphNodeConnectivityFunnel(WikiGraph{1},1,'direct')
%
% Algorithm:
%	Scales as O( numel(NodeIDs) ) and as O( N*log( max(ShellSize)), N - number of Nodes in graph. ShellSize(d) - number of nodes at distance d from source node.
%
% See Also:
%	mexNodeNeighbours,mexGraphNodeConnectivity
%																										
% Major Updates:
%	The algorithm is optimized. Consequently, execution speed reduced by a factor of ~4																			
