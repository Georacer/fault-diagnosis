function Graph = GraphGenerateCompleteGraph(n)
% Generates a complete graph of order n (Kn). In complete graph, each node is connected to all other nodes.
%
% Receives:
%   n       -   integer     -   Graph order. The number of nodes in graph
%
% Returns:
%   Graph   -   structure   -   The required graph. The format is identical to the one loaded with GraphLoad
%
% Example:
%   Graph =  GraphGenerateCompleteGraph(10); 
%
% See Also:
%   ObjectCreateGraph, GraphGenerateCompleteKPartiteGraph
%
% Algorithm:
%   http://mathworld.wolfram.com/CompleteGraph.html
%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

IndexValues = [1:n].';
IndexNames = num2str(IndexValues);

FromLinks = repmat(IndexValues,[1 n]).';
ToLinks = repmat(IndexValues,[n 1]);
Loops = find(FromLinks(:)==ToLinks);
FromLinks(Loops) = [];
ToLinks(Loops) = [];

LinksData = [ FromLinks(:) ToLinks(:) ones(n*(n-1),1)];

Graph = ObjectCreateGraph(LinksData,mfilename,'IndexNames',cellstr(IndexNames),'IndexValues',IndexValues);
Graph.FileName = '';