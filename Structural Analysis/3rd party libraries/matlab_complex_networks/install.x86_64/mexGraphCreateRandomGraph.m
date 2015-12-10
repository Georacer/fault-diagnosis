function Graph = mexGraphCreateRandomGraphRandomGraph(NumberOfNodes,DistributionX,DistributionY,Directional)
% Generates a graph of given size and with the given node's degree distribution.
%
% Receives:
%   NumberOfNodes   -   integer, scalar -   approximate number of nodes in Graph
%   DistributionX   -   integers, vector-   list of degrees. 
%   DistributionY   -   floats, vector  -   list of probabilities to have node approprieate degree
%                                           must have the same number of elements as 'DistributionX'
%                                           Must not be normalized 
%	Directional	-	boolean, scalar	-		(optonal) Specifies whether the graph is directional or undirectional. Deafult: 1 (true).
%											Directional graphs generation is much faster.
%
% Returns:
%   Graph           -   struct, graph   -   Object created with ObjectGraphCreateRandomGraph an d containing the 
%                                           desired graph
% Example:
%   Graph = mexGraphCreateRandomGraphRandomGraph(1000,[1 : 200],[1 : 200].^-2);
% 
% See Also:
%	 ObjectCreateGraph
%
