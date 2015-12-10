function FlowHierarchy = mexGraphFlowHierarchy(Graph,MaxDeapth)
% Builds node hierarchy such that nodes are only linked to nodes with smaller degrees. 
% For example, Nodes with no outgoing links will have flow hierarvhy score of 0; nodes, pointing to nodes
% with score 0 only will have score 1. Nodes, which can not be ordered in this hierarchy have score of NaN.
% The function always scans the directed network in original direction. To reverse it, apply GraphReverseLinks.m 
%
% Receives:
%	Graph			-	Graph Struct	-	The same graph with node numbers re-enumerated
%	MaxDeapth		-	integer			-	(optional) Deturmins the maximal score. Used to limit search time in huge graphs. Default: inf
%	
% Returns:
%	FlowHierarchy	-	struct			-	The struct, containing Flow Hierarchy Score for each node:
%							FlowHierarchy.Node		-	vector of integers	-		for each node in graph, it's index
%							FlowHierarchy.Score		-	vector of integers	-		for each node in graph, it's score
%							FlowHierarchy.k			-	vector of integers	-		list of all available scores (0<=k<=MaxDeapth<inf)
%							FlowHierarchy.Hist		-	vector of integers	-		for each score k, the number of nodes having this score
%							FlowHierarchy.Average	-	real scalar			-		Weighted Average Score. Does not consider nodes with score NaN.
%
%

