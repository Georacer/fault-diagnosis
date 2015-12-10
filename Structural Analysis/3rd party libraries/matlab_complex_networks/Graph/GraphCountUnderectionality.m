function Result = GraphCountUnderectionality(Graph)
% Computes the number of single and double-connected nodes in graph. 
% 
% Receives:
%   Graph       -   Graph Struct    -   the graph loaded with GraphLoad
%
% Returns:
%   Result      -   struct          -   
%
%       .TotalIndexedNodes          -   integer -   total number of indexed nodes. NAN if no index.
%       .TotalConnectedNodes        -   total number of connected nodes
%       .SourceNodes                -   integer -   number of nodes with non-zero outgoing links
%       .DestinationNodes           -   integer -   number of nodes with non-zero incoming links
%       .TotalLinks                 -   integer -   total number of links
%       .DoubleLinks                -   integer -   number of links which have corresponding link, going into oposite direction
%       .DuplicateLinks             -   integer -   number of duplicate links - links wich appear more then once. See GraphRemoveDuplicateLinks
%       .DoubleConnectedPairs       -   integer -   numeber of pairs of nodes which are double connecte .DuplicateLinks/2. Pairs are not ordered (i,j) and (j,i) are countered once.
%       .DoubleConnectivityFraction -   integer -   fraction of the connected pairs which are double-connected.
%
% Remarks:
%   Number of directly connected pairs of nodes: 
%       Result.TotalLinks-Result.DuplicateLinks 
%   Number of possible links (if all connected nodes were fully connected)
%       Result.TotalConnectedNodes*(Result.TotalConnectedNodes-1)
%   Number of fully connected pairs (connected in both directions)
%       Result.DoubleLinks/2 
%       
% See Also:
%       GraphLoad,GraphRemoveDuplicateLinks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

Result = [];

Result.TotalLinks       = size(Graph.Data,1);
if Graph.Index.Exist
    Result.TotalIndexedNodes = numel(unique(Graph.Index.Values));
else
    Result.TotalIndexedNodes = NaN;
end
Result.TotalConnectedNodes = numel(unique(Graph.Data(:,1:2)));
Result.SourceNodes      = numel(unique(Graph.Data(:,1)));
Result.DestinationNodes = numel(unique(Graph.Data(:,2)));


ReversedLinks = [Graph.Data(:,2) Graph.Data(:,1)];
MaxNodeIndex = (max(max(ReversedLinks))+1);
DirectIndeces = Graph.Data(:,1)*MaxNodeIndex+ Graph.Data(:,2);
InverseIndees = ReversedLinks(:,1)*MaxNodeIndex + ReversedLinks(:,2);

Result.DoubleLinks    = numel(intersect(DirectIndeces,InverseIndees));
Result.DuplicateLinks = numel(DirectIndeces)-numel(unique(DirectIndeces));
Result.DoubleConnectedPairs =Result.DoubleLinks/2;
Result.DoubleConnectivityFraction =2*Result.DoubleConnectedPairs / (Result.TotalLinks-Result.DuplicateLinks);
