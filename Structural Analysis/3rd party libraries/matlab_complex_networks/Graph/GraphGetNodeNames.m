function NodeNames = GraphGetNodeNames(Graph,NodeIDs)
% Returns the list of node Names, specified in the index of the graph
%
% Receives:
%       Graph      -   Graph Struct           -    the graph loaded with GraphLoad
%       NodeIDs    -   vector of integers     -    (optional) list of ids for which the names are required. Default: all nodes are returned.
%                                                   Values, not in the original index are empty cells.
% Returns:
%      NodeNames   -   cellstring             -    Names of the IDs in the order, identical to NodeIDs, If no IDs exist in the Graph, then empty cell is returen
% See Also:
%       GraphLoad, GraphGetNodeProperty
%

error(nargchk(1,2,nargin));
error(nargoutchk(0,1,nargout));

if ~exist('NodeIDs','var')
    NodeIDs = GraphNodeIDs(Graph);
end

NodeNames = {};
if isfield(Graph,'Index') & isfield(Graph.Index,'Values')
    [c,ia,ib] = intersect(NodeIDs,Graph.Index.Values);
    NodeNames(ia) = Graph.Index.Names(ib);
    EmptyEntriesIndex = find(cellfun('isempty',NodeNames.')==1);
    NodeNames(EmptyEntriesIndex.') = {' '};
    NodeNames = NodeNames(:);
end