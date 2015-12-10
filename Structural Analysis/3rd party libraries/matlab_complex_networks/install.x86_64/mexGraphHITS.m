function PageRank = mexGraphHITS(Graph, Iterations,  Direction, ShowProgress)
% Implements the HITS(????) algorithm on the Graph. The algorithm computes  interactively HUBS and AUTHORITIES indeces for each nodes.
%
% Receives:
%   Graph			-   struct			-   Graph, created with GraphLoad
%	Iterations		-	scalar, integer	-	(optional) Number of iterations performed on the network. Default: []. equals 50.
%   Direction		-   string			-   (optional) The way the passes are followed: 'direct','inverse' or 'both'. Default: 'direct' 
%   ShowProgress	-   boolean			-   (optional) Since the execution time may be very long, this option will cause the mex-file
%											to produce output in the MatLab prompt that update the user on the computation progress 
%											and execution time forecast.
%
% Returns:
%   PageRank		-	structure		-	The result of the PageRank algorithm application
%			.Average		-	2xIterations, float		-	Average score at each iteration. Can be user as approximate measure of convergence.
%			.NodeID			-	vector, integer			-	List of Node IDs.
%			.PageRank		-	vector, floats			-	List of PageRank scores for each node.
%
% Algorithm:
%		"Authoritative Sources in a Hyperlinked Environment", Jon M. Kleinberg, page 9.
% 	
%	
%	
%	
%
% Example:
%
%
%
% See Also:
%	 GraphLoad
%

