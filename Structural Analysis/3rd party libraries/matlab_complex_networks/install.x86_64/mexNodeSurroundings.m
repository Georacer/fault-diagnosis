function Neightbours = mexNodeSurroundings(Graph,NodeIDs,Distance,Direction)
% For each requested node, a list of neighbours for each distance (up the the specified) is returned
% The function is a general case of mexNodeNeighbours which concentrates on single distance only. It is 
% slightly less efficient.
%
% Receive:
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeIDs		-	integer			-	the ID of the node for whitch the neighbours are searched.
%					vector			-	List of IDs, in this case cell array lists of neighbours is returned.
%	Distance	-	integer			-	The distance up to witch to look. The computation time may increas with the distance dramatically (especially for densly connected graphs).
%	Direction	-	string			-	(optional) Either 'direct' or 'inverse'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
%
%
% Returns: 
%	Neightbours	-	cell array, (Distancex1)	-	If NodeID is scalar, cell array of vectors is returned. Each vector lists the neighbors at the appropiate distance. 
%													The first element is 0-distance (the node itself). Second - immidiate neighbours, etc.
%					cell array					-	If NodeID is vector, cell array is returned. Each cell is cell array on it's own, representing neigbours of the 
%													appropriate node. (see above).
% 
% See Also:
%	ObjectCreateGraph , GraphLoad, mexNodeNeighbours
%																										
