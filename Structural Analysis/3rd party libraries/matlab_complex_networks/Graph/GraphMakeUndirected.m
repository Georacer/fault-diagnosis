function Graph = GraphMakeUndirected(Graph)
% Reverses and duplicates each directional link in graph. If there exists a link A->B, then B->A is added. 
%
% Receives:
%   Graph       -   Graph Struct    -   the graph loaded with GraphLoad
%
% Returns:
%   Graph       -   Graph Struct    -   the graph loaded with GraphLoad without duplicate links
%
% See Also:
%       GraphLoad, GraphRemoveDuplicateLinks, GraphReverseLinks
%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

ReversedLinks = [Graph.Data(:,2) Graph.Data(:,1) Graph.Data(:,3)];
Graph.Data = [ReversedLinks; Graph.Data];
Graph = GraphRemoveDuplicateLinks(Graph);
