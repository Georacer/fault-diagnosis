function KCC = mexGraphLinkDirectionality(Graph,Nodes,Direction,MaxDeapth)
% Extends the mexGraphKClusteringCoefficient and computes for each link, 
% the number of times it was followed in each directions while performing BFS for all specified nodes.
% In this case, directions are defined by BFS. Starting from a node i, when the algorithms gets to a node j,
% Each link leaving j can lead either inward (to one of the already covered shells), atward (to nodes at the current shell) 
% or outward (to the next shell). 
% Tendency of a links (or average over all links) to follow specific direction can be interpreted as directionality.
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
%           LinksData                              - # of links x 5                 -   Detailed data about the number of times each links was followed in each direction. 
%                                                                                       Each line i.  corresponds to a link. 
%
%
%
% Algorithm:
%       D. J. Watts and S. H. Strogatz. Collective dynamics of 'small-world' networks, Nature, 393:440-442 (1998)
%
% See Also:
%	ObjectCreateGraph , GraphLoad
%