function  NewrestNeighborData = mexGraphAverageNearestNeighborDegree(Graph,Nodes,Direction)
% For each node, computes average degree (Incoming, Outgoing and Both) of it's neighbours
%	Important: the function will fail (and crash MatLab) if the nodes in graph are not consequent. User must use
%		mexGraphSqueeze
%
% Receives:
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeIDs		-	vector of indeces	-	(optional) List the ID of the node for whitch the coefficient is computed.
%										If Nodes is an empty matrix, all graph nodes are used. 	Default: [] 
%	Direction	-	string			-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	NewrestNeighborData	-	struct	-	The struct, containing the computed data.
%	
%					NodeIDs						-	IDs of all processed nodes.
%                   NodeDegree					-	for each node, the number of neighbors when the links are followed in the specified direction
%					NodeInDegree				-	for each node, the number of nodes, pointing to it
%					NodeOutDegree				-	for each node, the number of nodes to which it points
%					NodeAverageNeiborsInDegree	-	for each node, average incoming degree its neighbours when the links are followed in the specified direction
%					NodeAverageNeiborsOutDegree	-	for each node, average outgoing degree its neighbours when the links are followed in the specified direction
%					AverageNeiborsInDegree		-	for each degree (see Degree field) the average incoming degree all nodes whith that degree
%					AverageNeiborsOutDegree		-	for each degree (see Degree field) the average outgoing degree all nodes whith that degree
%                   Degree						-	All degrees (see NodeDegree field) encountered in the graph
%					DegreeHistogram				-	For each of the degrees (see Degree field), the number of nodes having it.
% 
%
% Algorithm:
%   PHYSICAL REVIEW E 67, 056104 (2003), Growing network with local rules: Preferential attachment, clustering hierarchy, and degree correlations
%	Alexei Vazquez, Department of Physics, University of Notre Dame, Notre Dame, Indiana 46556 (Received 23 November 2002; published 7 May 2003)
%	
% See Also:
%	ObjectCreateGraph , GraphLoad
%																										
