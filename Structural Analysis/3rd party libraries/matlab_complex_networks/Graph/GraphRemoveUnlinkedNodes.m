function [Graph, varargout] = GraphRemoveUnlinkedNodes(Graph,SkeepSqueeze)
% Removes the names and properties of the nodes which do not have links.
%
% Receives:
%       Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%       SkipSqueeze     -       boolean -   (optional) If true (~=0), the mexGraphSqueeze function is not called after the graph is loaded. Default: 0
%
% Returns:
%       Graph               -   Graph Struct -   the loaded graph
%		LUT             -	Nx2 of integers	-	(optional)  Look up table of the size Nx2 (N - number of nodes in the graph) with the
%                                                                           order in which the node's numbering was changed. Can be used for corresponding ordering
%                                                                           of other node parameters.    See 'mexGraphSqueeze'
%
% See Also:
%       GraphLoad, mexGraphSqueeze
%


error(nargchk(1,inf,nargin));
error(nargoutchk(0,2,nargout));

if ~exist('SkeepSqueeze','var')
    SkeepSqueeze = 0;
end

LinkedNodes = unique(Graph.Data(:,1:2));

if isfield(Graph,'Index')
   [ NodesToRemove ia]= setdiff( Graph.Index.Values,LinkedNodes);
    Graph.Index.Names(ia) = [];
    Graph.Index.Values(ia) = [];
    if isfield(Graph.Index,'Properties')
        for i = 1 : numel(Graph.Index.Properties)
            [NodesToRemove ia]= setdiff( Graph.Index.Properties(i).NodeIDs,LinkedNodes);
            Graph.Index.Properties(i).NodeIDs(ia) = [];
            Graph.Index.Properties(i).Values(ia) = [];
        end
    end
end

if ~SkeepSqueeze & nargout>1
    [Graph varargout{1}]= mexGraphSqueeze(Graph);
elseif ~SkeepSqueeze
    Graph = mexGraphSqueeze(Graph);
end