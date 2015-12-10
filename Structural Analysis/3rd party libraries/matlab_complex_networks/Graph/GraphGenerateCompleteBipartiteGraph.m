function Graph = GraphGenerateCompleteBipartiteGraph(m,n)
% Generates a cpmplete bipartite graph of order n (Km,n) with 2 independent groups of noded: m & n. Each node in group 1(2) is linked to each node in group 2(1)
%
% Receives:
%   m,n       -   integer     -   The number of nodes in each independent group. Graph order is n+m. 
%
% Returns:
%   Graph   -   structure   -   The required graph. The format is identical to the one loaded with GraphLoad
%
% Example:
%   Graph =  GraphGenerateCompleteBipartiteGraph(2,3); 
%
% See Also:
%   ObjectCreateGraph, GraphGenerateCompleteGraph, GraphGenerateCompleteKPartiteGraph
%
% Algorithm:
%   http://mathworld.wolfram.com/CompleteBipartiteGraph.html

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));

IndexValues = [1:(m+n)].';
IndexNames = num2str(IndexValues);

V1 = [1:m].';
V2 = [(m+1):(m+n)].';

FromLinks1 = repmat(V1,[1 n]).';
ToLinks1 = repmat(V2,[1 m]);

FromLinks2 = repmat(V2,[1 m]).';
ToLinks2 = repmat(V1,[1 n]);

LinksData = [[FromLinks1(:); FromLinks2(:)] [ToLinks1(:); ToLinks2(:)]];

Graph = ObjectCreateGraph(LinksData,mfilename,'IndexNames',cellstr(IndexNames),'IndexValues',IndexValues);
Graph.FileName = '';
