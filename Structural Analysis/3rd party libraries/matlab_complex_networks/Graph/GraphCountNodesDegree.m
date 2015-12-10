function Degree = GraphCountNodesDegree(Graph,Nodes)
% Computes and returns the degree (number of incoming & outgoing links) for each node in graph or for the specified nodes only
% 
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%   Nodes       -   vector of ids or single id                  -   (optional) for which nodes to return the degree. 
%                                                                   If any of the nodes do not exist in the graph, their degrees are 0. Default: [] - all nodes.
%
% Returns:
%   Degree  -   matrix Nodesx3                              -       3-column matrix of degree for each node. col 1: node number, col2 : in-degree, col3-out-degree.
%
% See Also:
%       GraphLoad, GraphPlotNodesDegreeDistribution, GraphNodeIDs, GraphCountNodeDegree
%
% Major Updates:
%   1. Optional parmeter 'Nodes' added
%   2. The function can be called with scalar 'Nodes' (for single node)
%   3. It takes almost the same time to compute for any size of 'Nodes'. 
%       The function computes degree of each node (using 'hist') and filters them with 'Nodes'
%   4. A bug, causing occasional aggregation of degrees between different (adjustent) nodes is corrected.
%   5. Graph can no longer be a file name, just a struct, loaded with GraphLoad.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error(nargchk(1,2,nargin));
error(nargoutchk(0,1,nargout));

try 
    ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');
    AllNodes = GraphNodeIDs(Graph);
    % AllNodes = unique(Graph.Index.Values);
    if ~exist('Nodes','var')        
        Nodes = []; 
    else
        AllNodes = unique([AllNodes; Nodes(:)]);
    end
    Degree = zeros(numel(AllNodes),3);
    Degree(:,1) = AllNodes;
    Degree(:,2) = hist(Graph.Data(:,2),AllNodes)';
    Degree(:,3) = hist(Graph.Data(:,1),AllNodes)';
    
    if ~isempty(Nodes)
        [c,ia] = setdiff(AllNodes,Nodes);
        Degree(ia,:)  = [];        
    end
catch
    Degree  =   [];
end