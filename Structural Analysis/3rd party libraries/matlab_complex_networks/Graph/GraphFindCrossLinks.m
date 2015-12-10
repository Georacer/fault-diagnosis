function CrossLinks  = GraphFindCrossLinks(Graph, Nodes)
% Finds and returns all existing graph links that run between any of the nodes in the supplied list. 
% the function can be used for instance to compute clustering coefficient (though a much more efficience designated function exists). 
%   
% Receives:
%   Graph       -   Graph Struct            -   the graph loaded with GraphLoad
%   Nodes       -   vector of integers      -   list of node ids
% Returns:
%       Selected    -   string  -   The name of the selected variable. Empty ('') if cancel is clicked,
%                   
% See Also:
%   mexGraphClusteringCoefficient
%
% Example:
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));

if numel(Nodes)>=2
    MaxNodeID = max(max(Graph.Data(:,[1 2])));
    LinksIndeces = MaxNodeID.*repmat(Nodes(:),[1 numel(Nodes)]) + repmat(Nodes(:).', [numel(Nodes) 1]);
    LinksIndeces = LinksIndeces-eye(size(LinksIndeces)).*LinksIndeces; % remove diagonal
    [~, ai, ~] = intersect(Graph.Data(:,1)*MaxNodeID + Graph.Data(:,2),setdiff(LinksIndeces(:),0));
    CrossLinks   = Graph.Data(ai,[1 2]);
else
    CrossLinks  = [];
end