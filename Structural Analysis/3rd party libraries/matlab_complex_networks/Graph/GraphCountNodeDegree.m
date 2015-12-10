function Degree = GraphCountNodeDegree(Graph,NodeID)
% Computes and returns the degree (number of incoming & outgoing links) for the specified node in graph.
% Unlike 'GraphCountNodesDegree' operates with single node only, but much more effective.
%
% Receives:
%   Graph       -   Graph Struct          -   the graph loaded with GraphLoad
%   Node          -   single id                  -   The ID of the node to be returned. The ID may not  be in the graph - (0,0) will be returned.
%
% Returns:
%   Degree      -   2x1 vector of integer   -   Degree(1) - incoming node degree, Degree(2) - outgoing.
%
% Remarks:
%       For efficiency, the function does not validate that Graph  indeed represents Graph
%
% See Also:
%       GraphLoad, GraphCountNodesDegree
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));

Degree = [0 0];
Degree(1) = nnz(Graph.Data(:,2)==NodeID);
Degree(2) = nnz(Graph.Data(:,1)==NodeID);