function [ShortesPaths, varargin] = mexGraphAllNodeShortestPaths(Graph,Node,Direction)
% For the specified node in graph, the function returns a list of ALL shortes paths to each of the nodes, connected to the Node.
%
% Receives:
%       Graph       -   Graph Struct			-   the graph loaded with GraphLoad
%		NodeIDs		-	array of Node IDs    	-	(optional) 1 or more node ids for which to compute the paths. If empty, all nodes are used. Note that this may result in huge memory requirements O(N*N*<d>) where N - number of nodes in graph and <d> - average path length. 
%		Direction	-	string					-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are followed.
%
% Returns:
%		ShortesPaths		- struct array				-  a array of structs containing path details for each of the source nodes. 
%			NodeID			-	 uint32, scalar			- id of the source node. 
%			DestNodeIDs     -    uint32, vector  		- ids of the destination nodes. 
%			Paths           -    cell array				-	each cell contains the shortest path to the corrsponding destination node. The source node is not included (to preserve space). Note that only one path (with lowest node IDs) between the source and the destination is returned. 
%			PathHistogram   -    uint32, vector			-  cell with index i contains the number of paths of length i originating from the source node. 
%			MeanPathLength	-    double, scalar			-	average path lenth. 
%
%		PassLengthHistogram	- array						-  (optional) Contains number of shortest paths initiated at the specifield node for each length. 1'st element is always 1 as there is only 1 pass of length 0 ([Node]).
%		NodeIDs			    - vector of ints			- (optional) list of source node IDs
%
% Example:
%	Graph = mexGraphCreateRandomGraph(1000,[1 : 200],[1 : 200].^-2);;
%	[Paths,  NodeIDs]= mexGraphAllNodeShortestPaths(Graph,[1 : 10], 'direct');
%
% See Also:
%       GraphBetweennessCentrality,  mexGraphNodeConnectivityFunnel (probably, better if just a distance to each of the nodes is needed). 
%
