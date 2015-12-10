function Graph = GraphGenerateCompleteKPartiteGraph(GroupSizes)
%Generates a complete k-Partite graph. sum(GroupSizes) of nodes are split into numel(GroupSizes) groups. Nodes in each groups are connected to all nodes outsized their group.
%
% Receives:
%   GroupSizes    -   vector of integers     -   List of group sizes. The graph will have sum(GroupSizes) nodes.
%
% Returns:
%   Graph   -   structure   -   The required graph. The format is identical to the one loaded with GraphLoad
%
% Example:
%   Graph =  GraphGenerateCompleteKPartiteGraph(2,3); 
%
% See Also:
%   ObjectCreateGraph, GraphGenerateCompleteGraph, GraphGenerateCompleteBipartiteGraph
%
% Algorithm:
%   http://mathworld.wolfram.com/CompleteBipartiteGraph.html
%

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));


Groups = {};
Degree = 0;
for n = GroupSizes(:)
    Groups{end+1} = Degree+1 : n+Degree;
    Degree = Degree + n;
end
error('not implemented yet');
