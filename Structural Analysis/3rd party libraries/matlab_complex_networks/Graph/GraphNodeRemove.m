function Graph = GraphNodeRemove(Graph, Nodes)
% Remove a node or a list of nodes from the graph. The graph is squeezed after the nodes are removed.
%
%
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%   Nodes       -   vector                                            -   list of nodes to be removed from the graph.
%
% Returns:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%
% See Also:
%       GraphLoad, mexGraphSqueeze
%
% Major Changes:
%   A minor bug, related to delition of removed node names is corrected.

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));

ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');

IndecesX = [];
for i = 1 : numel(Nodes)
    [CurrentIndecesI       CurrentIndecesJ] = find(Graph.Data(:,1:2)==Nodes(i));
    IndecesX = [IndecesX; CurrentIndecesI ];
end
IndecesX = unique(IndecesX);
Graph.Data(IndecesX,:) = [];
if isfield(Graph,'Index')
    IndecesX = [];
    for i = 1 : numel(Nodes)
        CurrentIndeces = find(Graph.Index.Values==Nodes(i));
        IndecesX = [IndecesX CurrentIndeces ];
    end
    if ~isempty(IndecesX)
        Graph.Index.Names(IndecesX) = [];
        Graph.Index.Values(IndecesX) = [];
    end
end
%
% if numel(Nodes) < 0.5*GraphCountNumberOfNodes(Graph)
%     for i = 1 : numel(Nodes)
%         [CurrentIndecesI       CurrentIndecesJ] = find(Graph.Data(:,1:2)==Nodes(i));
%         IndecesX = [IndecesX; CurrentIndecesI ];
%     end
%     IndecesX = unique(IndecesX);
%     Graph.Data(IndecesX,:) = [];
% else
%     Nodes = setdiff([1 : GraphCountNumberOfNodes(Graph)],Nodes);
%     Data = zeros(0,3);
%     for i  = 1 : numel(Nodes)
%         [CurrentIndecesI       CurrentIndecesJ] = find(Graph.Data(:,1:2)==Nodes(i));
%         IndecesX = [IndecesX; CurrentIndecesI ];
%     end
%     IndecesX = unique(IndecesX);
%     Data = Graph.Data(IndecesX,:);
% end


Graph =  mexGraphSqueeze(Graph);

