function C = mexGraphConstraint(Graph,Nodes,Direction)
% Remarks:
% - The function does not assume that nodes are adjusted (no missing nodes) or even sorted (=>performance penalty)
% - The function oerates on weights.
% -
% Computes the clustering coefficient for any of the supplied nodes of the Graph.
% By deffinition (Collective dynamics of ‘small-world’ networks Duncan J. Watts* & Steven H. Strogatz), 
% the clusterung coefficient Ck of the node k is the ratio of neigbours of the node k, connected between them.
% Strogatz: The clustering coefficient C(p) is defined as follows. Suppose that a vertex v has kv neighbours; then at most kv?kv 21?=2 edges can exist
% between them (this occurs when every neighbour of v is connected to every other neighbour of v). Let Cv denote the fraction of these allowable edges that actually
% exist. Define C as the average of Cv over all v.
%
% Receives:	
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeIDs		-	vector of indeces	-	(optional) List the ID of the node for whitch the coefficient is computed.
%										If Nodes is an empty matrix, all graph nodes are used. In that case, 'All Nodes' are defined as [All nodes are defined as: [1 : MaxNodeID].	
%										Default: [] 
%	Direction	-	string			-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	Ck			-	structure - the structure, containing detailed clustering information about the supplied graph
% 			Field Name							-		Field Type					-	Detailes
%				NodeIDs									-		array	of integers 	- 	Lists IDs of nodes for which the processing was done.
%				NodeDegrees							-		array of integers		-	 	For each node, Degree of each node (see Direction)
%				NodeNeighboursLinks			-		array of integer		-		For each node, Number of links between it's neighbors
%				NodeConstraint-	array of double			-		For each node, the clustering coefficient: NodeNeighboursLinks/NodeDegrees/(NodeDegrees+1)
%				Ck											-		array of double			-		For each node degree, an average clustering coefficient of all nodes having this degree
%				k												-		array of integers		-		Degrees used in Ck.
%				C												-		double							-		Average clustering coefficient of all nodes, having their degree > 1. 
%				Cave											-		double							-		Average clustering of all nodes, without filtering out nodes with degree of 0 or 1.
%
%
%
% Algorithm:
%      http://igraph.sourceforge.net/doc/R/constraint.html
%
% See Also:
%	ObjectCreateGraph , GraphLoad
%																										
% Major Update,
% 	The function now returns a struct containing detailed information about clustering coefficient
%
%% Major Update,
% 	The function now accepts 'both' as direction
%
% Major Update,
% 	Dramatically Optimized. >300,000 WWW sites are processed in ~7secs against >140 secs before!
%
% Major Update,
%     Normalization of the CC corrected due to the bug reported by Tom Erez. The **wrong** normalization was Ki(Ki+1) instead of Ki(Ki-1)
%
% Major Update,
%     Cave field added to the output.
%
% Major Update
%    The function is optimized. Execution time reduced by a factor of 3.
%	