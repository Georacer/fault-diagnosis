function NodeIDs = GraphNodeIDs(Graph)
% Returns the list of node IDs in the graph
%
% Receives:
%       Graph      -   Graph Struct           -    the graph loaded with GraphLoad
%
% Returns:
%      NodeIDs    -     vector of integers    -    IDs of nodes, used in graph
% See Also:
%       GraphLoad
%
% Major Changes:
%   Can now handle Index.Values in either row or column form

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

NodeIDs = unique(Graph.Data(:,1:2));
if isfield(Graph,'Index') && isfield(Graph.Index,'Values')
    NodeIDs  = unique([NodeIDs; Graph.Index.Values(:)]);
end