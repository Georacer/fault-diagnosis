function Components = GraphComponents(Graph)
% Finds connected components in the given graph. Graph is converted to undirected
%
% Receives:
%   Graph       -   Graph Struct         -   the graph loaded with GraphLoad
%
% Returns:
%   Components  -   cells of arrays     - each cell represents a connected component and contains ids of nodes
%                                           belonging to it.
%
% See Also:
%       GraphLoad, GraphCountNumberOfLinks
%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

Graph = GraphMakeUndirected(Graph);
Components = {};
NodeIDs = unique(Graph.Data(:,1:2));
Proceed = 1;
while  ~isempty(NodeIDs)
    Neightbours = mexNodeSurroundings(Graph,NodeIDs(1),20);
    NeightboursIDs = [];
    for i = find( cellfun('length',Neightbours)).'
        NeightboursIDs = [NeightboursIDs; Neightbours{i}];
    end
    Components{end+1} = unique(NeightboursIDs);
    NodeIDs = setdiff(NodeIDs,NeightboursIDs);
end
%{
Components = {};
Proceed = 1;
while  numel(Graph.Data)>0
    Degrees = GraphCountNodesDegree(Graph);
    MostConnectedNodeID = Degrees( find(max(Degrees(:,2))==Degrees(:,2),1,'first'),1);
    Neightbours = mexNodeSurroundings(Graph,MostConnectedNodeID,10);
    NeightboursIDs = [];
    for i = find( cellfun('length',Neightbours)).'
        NeightboursIDs = [NeightboursIDs; Neightbours{i}];
    end
    Components{end+1} = unique(NeightboursIDs);
    Graph = GraphNodeRemove(Graph,Components{end});
end
%}