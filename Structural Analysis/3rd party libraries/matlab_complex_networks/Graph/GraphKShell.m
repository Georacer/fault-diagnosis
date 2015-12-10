function [KShell, varargout] = GraphKShell(Graph,K)
% Returns the complementary part of the K-Core of the goven graph.
%
% Receives:
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	K			-	integer, >0		-	K-degree of the K-core.
%
% Returns:
%   KShell      -   Graph Struct    -   The original graph with all nodes, belonging to the K-Core removed.
%   KCore       -   Graph Struct    -   (optional) The K-core of the original graph. 
%
% Remarks:
%   Notice, that each node in the original Graph is hosted in either K-Shell or K-Core. 
%   Links  between nodes of each resultant graph (KShell of KCore) from the original Graph are kept,
%   However, links between any node in KCore and any node in KShell are dropped.
%
% See Also:
%   mexGraphKCore
%
%

error('NOT IMPLEMENTED YET!');
%{
error(nargchk(2,2,nargin));
error(nargoutchk(0,2,nargout));

KCore = mexGraphKCore(Graph,K);
KShell = GraphNodeRemove(Graph,GraphNodeIDs(KCore));

if nargout>1
    varargout{1} = KCore;
end
%}