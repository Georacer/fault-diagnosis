function [Circles CirclesHistogram] = mexGraphCountCircles(Graph, MaxCircleLength)
% Finds all circles in UNDIRECTED graph. Each received graph is converted to undirected.
%
% Receives:
%       Graph       -			Graph Struct			-   the graph loaded with GraphLoad
%		MaxCircleLength	-		scalar					-	(optional) maximal length of the circle to search for. default - 10
%
% Returns:
%		Circles		- struct	-  a struct which contains all the circles of each degree 
%		CirclesHistogram	- array	-  (optional) Contains number of shortest circles initiated of each length. 
%  
% Example:
%	Graph = GraphLoad('E:\Projects\Evolution\Results\Evolution103._0_0\Evolution103.83.Graph');
%	[A  B]=  mexGraphCountCircles(Graph)
%
% See Also:
%       mexGraphAllNodeShortestPasses
%
