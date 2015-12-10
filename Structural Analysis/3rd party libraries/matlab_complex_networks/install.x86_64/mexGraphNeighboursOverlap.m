function [Overlap, Degrees1, Degrees2]= mexGraphNeighboursOverlap(Graph,NodeIDs1, NodeIDs2,Direction)
% Computes the ammount of overlapping neignours between each node in SourceNodeID and in DestinationNodeID
%
% Receives:
%	Graph			-	Graph Struct		-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeIDs1		-	vector of indeces	-	list of node IDs
%	NodeIDs2		-	vector of indeces	-	list of node IDs
%
%	Direction	-	string			-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
% Returns:
%	Overlap			-	numel(NodeIDs1) x numel(NodeIDs2) matrix of integers	-	Element Overlap(i,j) of the matrix contains the number of neighbours, common to nodes NodeIDs1(i) and NodeIDs2(j)
%	Degrees1		-	1xNodeIDs1, of integers									-	(optional) Degree (number of neighbours) of each element in NodeIDs1
%	Degrees2		-	1xNodeIDs2, of integers									-	(optional) Degree (number of neighbours) of each element in NodeIDs2
%
