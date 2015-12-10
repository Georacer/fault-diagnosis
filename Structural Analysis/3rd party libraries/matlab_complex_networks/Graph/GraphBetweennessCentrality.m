function [BetweenneessCentrality, varargout]= GraphBetweennessCentrality(Graph,SourceNodes)
% Computes betweenneess centrality of each node. 
%   
% Receives:
%   Graph   -   Graph Struct           -    the graph loaded with GraphLoad
%   SourceNodes - array of double      -    (optional) nodes, from which passes start. Default: [] (all nodes).
%   
% Returns:
%   BetweenneessCentrality  -   array of double -   Betweenneess Centrality for each node.
%   Nodes                   -   array of double -   (optional)List of all nodes for which betweennessn centrality is computed
%
% Algorithm:
%   http://www.boost.org/libs/graph/doc/betweenness_centrality.html
%
% See Also:
%       mexGraphAllNodeShortestPasses
%

warning('Use the more optimized mexGraphBetweennessCentrality.dll');

error(nargchk(1,2,nargin));
error(nargoutchk(0,2,nargout));

if ~exist('SourceNodes') | isempty(SourceNodes)
    SourceNodes = unique(Graph.Data(:,1));
end
Nodes = unique(Graph.Data(:,1:2));
%TotalPasses = zeros(GraphCountNumberOfNodes(Graph),GraphCountNumberOfNodes(Graph));
Betweenness = zeros(GraphCountNumberOfNodes(Graph),1);

for Node = Nodes(:).'
    [ShortesPasses PassesHistogram]= mexGraphAllNodeShortestPasses(Graph,Node);
    %TotalPasses = TotalPasses + sum(PassesHistogram(2:end));
    tic
    for i = 1 : numel(ShortesPasses)
        %T = ShortesPasses(i).Passes(end);
        %TotalPasses(Node,ShortesPasses(i).Passes(end)) =  size(ShortesPasses(i).Passes,2); % compute total number of shortes passes from Node to some other node.       
        Passes = ShortesPasses(i).Passes(2:end-1,:);
        NodesOnTheWay = unique(Passes);
        if numel(NodesOnTheWay)==1
            Count = 1; % hist behaves differently in this case.
        else
            Count = hist(Passes(:),NodesOnTheWay);
        end
        Betweenness(NodesOnTheWay(:)) = Betweenness(NodesOnTheWay(:))+ Count(:)/size(ShortesPasses(i).Passes,2);
    end
    toc
    disp(Node)
end

if nargout>1
    varagout{1} = Nodes;
end