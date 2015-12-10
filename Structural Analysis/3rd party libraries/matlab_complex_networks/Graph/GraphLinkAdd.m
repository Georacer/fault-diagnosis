function Graph = GraphLinkAdd(Graph,Links,DontCallSqueezeGraph)
% Add a link or a list of links to the graph. Some of the added links might already be in the graph - no duplicates will be created. 
%
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%   Lists       -   vector   Nx2                                  -   list of links to be added to the graph. Each link is a 1x2 or 1x3 (with weights) vector of the source and destination node. The link may already exist on the graph.
%                                                                                        Hovewer no duplicates in the Links list itself is allowed (not tested). If 1x2 vector is supplied, weights of 1 are assumed.
%   DontCallSqueezeGraph    -   bool (1/0)       -  (optional) Specifies if the function calles the mexGraphSqueeze function before exiting. Default: 0. The user must rely on the default 
%                                                                                       since otherwize, the graph might not be valid. Only if the function is called by other function the parameter may be false to avoid change 
%                                                                                       of node numbers (see GraphLinkAdd)
%
% Returns:
%   Graph       -   Graph Struct                                -   the graph with with the links added.
%
% See Also:
%       GraphLoad, GraphLinkFind, GraphLinkRemove, mexGraphSqueeze,GraphNodeAdd
%


error(nargchk(2,3,nargin));
error(nargoutchk(0,1,nargout));

 ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');

 if ~exist('DontCallSqueezeGraph','var')
     DontCallSqueezeGraph = 0;
 end
 Graph = GraphLinkRemove(Graph, Links,1); % make sure there will be no duplicates. The mexGraphSqueeze is not called.
 if size(Links,2)==2
     Links = [Links ones(size(Links,1),1)];
 end 
 
 Graph.Data = [Graph.Data; Links];
 
 if ~DontCallSqueezeGraph
    Graph =  mexGraphSqueeze(Graph);
end