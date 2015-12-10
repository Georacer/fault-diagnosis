function Graph = mexGraphGeneratePoissonRandomGraph(N,p)
% Creates Erdos and Renyi directed graph of N nodes with probability p to have edge between every 2 nodes.
%
% Receives:
%	N			-	integer	-	Number of nodes in the graph.
%	p			-	floating point	-	Probability (0<=p<=1) for every couple of nodes to have edge connecting them
%
% Returns:
%   Graph		-   Graph Struct			-   the graph in the format, identical to the one, loaded with GraphLoad
%
% Algorithm:
%	"The structure and function of complex networks", Newman; Overview: Section 3,Section 4, Deatails: Section 4.1 
%
% See Also:
%	GraphGenerate*, ObjectCreateGraph
%
