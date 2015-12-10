function Graph = GraphLinkRemove(Graph,Links,DontCallSqueezeGraph)
% Remove a link or a list of links from the graph. The graph is squeezed (by default) after the links are removed (some nodes might disappear), changing other nodes indeces.
% 
%
%
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%   Lists       -   vector   Nx2                                  -   list of links to be removed from the graph. Each links is a 1x2 vector of the source and destination node. The link must not 
%                                                                                        exist on the graph.
%   DontCallSqueezeGraph    -   bool (1/0)       -  (optional) Specifies if the function calles the mexGraphSqueeze function before exiting. Default: 0. The user must rely on the default 
%                                                                                       since otherwize, the graph might not be valid. Only if the function is called by other function the parameter may be false to avoid change 
%                                                                                       of node numbers (see GraphLinkAdd)
%
% Returns:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%
% See Also:
%       GraphLoad, mexGraphSqueeze, GraphLinkFind


error(nargchk(2,3,nargin));
error(nargoutchk(0,1,nargout));

 ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');
 if ~exist('DontCallSqueezeGraph','var')
     DontCallSqueezeGraph = 0;
 end

 LinksIndeces = GraphLinkFind(Graph,Links);
 Graph.Data(LinksIndeces,:) = [];
 
 if ~DontCallSqueezeGraph
    Graph =  mexGraphSqueeze(Graph);
end