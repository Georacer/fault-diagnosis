function Graph = GraphRemoveDuplicateLinks(Graph)
% Removes duplicate links from the graph
%
% Receives:
%   Graph       -   Graph Struct    -   the graph loaded with GraphLoad
%
% Returns:
%   Graph       -   Graph Struct    -   the graph loaded with GraphLoad without duplicate links
%
% See Also:
%       GraphLoad, GraphCountNumberOfLinks
%
% Major Changes:
%   A multiplication factor is now : (NumberOfNodes+1) and not just NumberOfNodes. This could
%   cause problem in the extreme case when the last node was connected to the first node.

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

% NumberOfNodes  = GraphCountNumberOfNodes(Graph);
if size(Graph.Data,1)>0
    NumberOfNodes  = max(max(Graph.Data(:,1:2)));
    Indeces = Graph.Data(:,1)*(NumberOfNodes+1) + Graph.Data(:,2);
    [Indeces m n]=unique(Indeces);
    IndecesToKill = setdiff([1:GraphCountNumberOfLinks(Graph)],m);
    Graph.Data(IndecesToKill,:)=[];
end