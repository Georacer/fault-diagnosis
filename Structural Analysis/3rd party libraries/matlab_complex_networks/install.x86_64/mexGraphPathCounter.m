/*************************************************************************
function Result = mexGraphPathCounter(Graph,MaxRange, Nodes,Direction)
% Counts all possible paths from the specified nodes to the rest of the graph.
%
% Receives:	
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	MaxRange	-	integer			-	The maximal path length to follow.
%	NodeIDs		-	vector of indeces	-	(optional) List the ID of the node for whitch the coefficient is computed.
%										If Nodes is an empty matrix, all graph nodes are used. 	Default: [] 
%	Direction	-	string			-	(optional) Either 'direct' or 'inverse'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	Result		-	 cell array		- Cell array containing for each of the requested nodes, the number of paths of each length (<=MaxRange) leading to
%									  each of the possible destination nodes. 
%					Each cell of Result is  struct:
%						SourceNodeID	-	int	-	 id of the source node (at distance 0);
%						Shell			-	 cell array - each celll (i) contains nx2 array of integers 
%											where first column is id of a destination node and of path legth i and the second
%											column specifies the number of paths of that length.
%	
% 
% See Also:
%	ObjectCreateGraph , GraphLoad
%																										

*************************************************************************/