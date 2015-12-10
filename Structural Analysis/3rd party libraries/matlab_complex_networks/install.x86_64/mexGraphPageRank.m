function PageRank = mexGraphPageRank(Graph, Iterations, DampingFactor, Direction, ShowProgress)
% Computes the Google's PageRank algorithm on the Graph.
%
% Receives:
%   Graph			-   struct			-   Graph, created with GraphLoad
%	Iterations		-	scalar, integer	-	(optional) Number of iterations performed on the network. Default: []. equals 50.
%	DampingFactor	-	scalar, double	-	(optional) a value normaly in the range of (0,1) lowering the contribution of each 
%											node's rank to the network. See. Referencies: d or q in the formular. 
%											Default: [], equals 0.15.
%   Direction		-   string			-   (optional) The way the passes are followed: 'direct','inverse' or 'both'. Default: 'direct' 
%   ShowProgress	-   boolean			-   (optional) Since the execution time may be very long, this option will cause the mex-file
%											to produce output in the MatLab prompt that update the user on the computation progress 
%											and execution time forecast.
%
% Returns:
%   PageRank		-	structure		-	The result of the PageRank algorithm application
%			.Average		-	float, 1x	Iterations -	Average score at each iteration. Can be user as approximate measure of convergence.
%			.NodeID			-	vector, integer	-	List of Node IDs.
%			.PageRank		-	vector, floats	-	List of PageRank scores for each node.
%
% Algorithm:
%	"The pagerank citation ranking: Bringing order to the web" S Brin, R Motwani, T Winograd - 1998
%   http://www.webworkshop.net/pagerank.html
%	http://en.wikipedia.org/wiki/PageRank
%	"PageRank Uncovered", Chris Ridings, Mike Shishigin,Jill Whalen, Yuri Baranov
%	
%
% Example:
%
%
%
% See Also:
%	 GraphLoad
%
