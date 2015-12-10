function [ShortesPasses, varargin] = mexGraphAllNodeShortestPassesHistogram(Graph,Node,Direction)
% For the specified node in graph, the function returns a list of ALL shortes passes to each of the nodes, connected to the Node.
%
% Receives:
%       Graph       -   Graph Struct			-   the graph loaded with GraphLoad
%		Node		-	Node index				-	the index of the source node for all passes.
%		Direction	-	string					-	(optional) Either 'direct', 'inverse' or 'both'. Case insensitive. The incoming or outgoing links are followed.
%
% Returns:
%		ShortesPasses		- cell array				-  a cell array which contains all Shortes passes for each node connected to the 'Node' 
%		PassLengthHistogram	- array						-  (optional) Contains number of shortest passes initiated at the specifield node for each length. 1'st element is always 1 as there is only 1 pass of length 0 ([Node]).
%
% Example:
%	Graph = GraphLoad('E:\Projects\Evolution\Results\Evolution103._0_0\Evolution103.83.Graph');
%	[A  B]= mexGraphAllNodeShortestPassesHistogram(Graph,1);
%
% See Also:
%       GraphBetweennessCentrality
%
