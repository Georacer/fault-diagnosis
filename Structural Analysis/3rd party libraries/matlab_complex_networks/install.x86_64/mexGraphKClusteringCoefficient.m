function KCC = mexGraphKClusteringCoefficient(Graph,Nodes,Direction,MaxDeapth)
% Computes the K-clustering coefficient for any of the supplied nodes of the Graph.
% This algorithms generalizes the classical Clustering Coefficient (CC) computation. For each node, it arranges the network nodes in shells 
% so that the inner-most shell contains the node itself, the next shell - it's neighbours and each consequent shell - all neighbours  of the nodes in the preceeding shell not yet contained in that or earlier shells.
% This is effectively, a BSF arrangement of the network which may serve as 
% In undirected network (all links are reciprocal), one of the properties of this arrangement is that nodes in each shell can only point at nodes in  the same, previouse or next shell.
%
% Receives:	
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeIDs		-	vector of indeces	-	(optional) List the ID of the node for whitch the coefficient is computed.
%										If Nodes is an empty matrix, all graph nodes are used. In that case, 'All Nodes' are defined as [All nodes are defined as: [1 : MaxNodeID].	
%										Default: [] 
%	Direction	-	string			-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%	MaxDeapth	-	integer			-	(optional) maximal eapansion deapth. Default: inf
%
%
%
% Returns: 
%	KCC			-	structure - the structure, containing detailed clustering information about the supplied graph
% 			Field Name							-		Field Type					-	Detailes
%			KCCData					cell array with cell for every requested node		Each cell contains the details for the corresponding node
%										Cell Details:
%									NodeID
%									R
%									NodesIn
%									NodesAt
%									NodesOut
%									LinksIn
%									LinksAt
%									LinksOut
%									CCIn
%									CCAt
%									CCOut										
%
%			KCCDataAverage						-	array of structs 				- Each struct contains the averaged information about the KCC at the corresponding range
%									NumberOfNodes
%									R
%									NodesIn
%									NodesAt
%									NodesOut
%									LinksIn
%									LinksAt
%									LinksOut
%									CCIn
%									CCAt
%									CCOut										
%
%
%
% Algorithm:
%       D. J. Watts and S. H. Strogatz. Collective dynamics of 'small-world' networks, Nature, 393:440-442 (1998)
%
% See Also:
%	ObjectCreateGraph , GraphLoad
%																										
%