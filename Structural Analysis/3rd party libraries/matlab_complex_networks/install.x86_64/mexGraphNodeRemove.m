function Graph = mexGraphNodeRemove(Graph,Nodes)
% Removes from the graph all links wich involve any of the 'Nodes'. Does not call mexGraphSqueeze. 
% Node names are left as well (can be easily removed with intersect with Nodes). 
% This method is much faster then the GraphNodeRemove, especially for large number of Nodes.
%
% Receives:
%	Graph			-	Graph Struct		-	The same graph with node numbers re-enumerated
%	Nodes			-	vector of integer	-	List of nodes to remove.
%	
% Returns:
%	Graph			-	Graph Struct		-	The same graph with node numbers re-enumerated
%
