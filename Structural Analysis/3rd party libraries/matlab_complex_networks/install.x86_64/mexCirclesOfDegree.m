function [Circles CirclesHistogram] = mexCirclesOfDegree(Graph, SkipTrivialCircles)
% For the specified node in graph, the function returns a list of ALL
% shortes circles which are from degree of the minmum shortest circle to the 
% maximum shortest circle 
% Receives:
%       Graph       -			Graph Struct			-   the graph loaded with GraphLoad
%		SkipTrivialCircles -	boolean					-	(optional) If true, circles of type: i->j->i and i->j->k->j->i are skipped. 
%															This is usefull for undirected graphs. 
%															Default: false.
%
% Returns:
%		Circles		- struct	-  a struct which contains all the circles of each degree 
%		CirclesHistogram	- array	-  (optional) Contains number of shortest circles initiated of each length. 
%  
% Example:
%	Graph = GraphLoad('E:\Projects\Evolution\Results\Evolution103._0_0\Evolution103.83.Graph');
%	[A  B]=  mexCirclesOfDegree(Graph)
%
% See Also:
%       mexGraphAllNodeShortestPasses
% remarks:
%     the algorithem is based on the MST its check all the nodes so its O(n*E*log(E)) 
%Created:																							
%	Royi Itzhak  
%   toyi_its@yahoo.com
% based on Lev Muchnik Graph Tool box
		
