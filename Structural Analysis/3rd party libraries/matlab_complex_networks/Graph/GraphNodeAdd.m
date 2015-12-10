function Graph = GraphNodeAdd(Graph,NodeID,NodeName)
% Adds the specified Node(s) to the dictionary, If node with that ID already exists, it's name is changed.
%
%
% Receives:
%   Graph       -   Graph Struct                 -   the graph loaded with GraphLoad
%   NodeID      -   integer or vector of integers  -  the ID(s) of the node(s) to be added.
%   NodeName    -   string or cellstr           -   (list of) name(s) of the node. Must have the same nummber of elements as the NodeID vector
%
% Returns:
%   Graph       -   Graph Struct                -   the graph with with the node added to the dictionary.
%
% Remarks:
%   mexGraphSqueeze is not called - the node IDs are no changed. 
%
% See Also:
%       GraphLoad, GraphLinkFind, GraphLinkRemove, mexGraphSqueeze, GraphLinkAdd
%

error(nargchk(3,3,nargin));
error(nargoutchk(0,1,nargout));

if ~isfield(Graph,'Index')
    EmptyGraph = ObjectCreateGraph();
    Graph.Index = EmptyGraph.Index;
end
if numel(NodeID) ~= 1
    NodeID = reshape(NodeID,[numel(NodeID) 1]);
    NodeName = reshape(NodeName,[numel(NodeName) 1]);
else
    NodeName = cellstr(NodeName);
end
[c,ia,ib] = intersect(Graph.Index.Values,NodeID);
Graph.Index.Names{ia} = NodeName{ib};
ic = setdiff([1:numel(NodeID)],ib);
Graph.Index.Values = [ Graph.Index.Values; NodeID(ic)];
Graph.Index.Names = [ Graph.Index.Names; NodeName(ic)];