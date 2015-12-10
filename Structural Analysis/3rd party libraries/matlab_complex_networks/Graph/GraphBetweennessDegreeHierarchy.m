function [ Hierarchy ] = GraphBetweennessDegreeHierarchy(Graph,varargin)
% For each pair of nodes, computes the relative hierarchy based on the ratio of their betweenness and degree.
% 
% Receives:
%   Graph		-   Graph Struct        -    the graph loaded with GraphLoad. Make sure that mexGraphSqueeze is called. 
%   varargin    -   FLEX IO             -   The input is in FlexIO format.  The following parameters are allowed:
%                                               Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                                   Nodes               |   vector          |   yes         |       []        | List of nodes, for which the hierarchy is computed. If not provided (or if empty) all nodes are taken. Should match the 'Betweenness' and 'Degree' if any of them is provided.
%                                                   Betweenness         |   vector          |   yes         |       []        | Vector, returned from 'mexGraphBetweennessCentrality'. If not provided, the mexGraphBetweennessCentrality will be called. 
%                                                   Degrees             |   vector          |   yes         |       []        | Outgoing degree of each node. 3'rd column of the matrix, returned from 'GraphCountNodesDegree'. If not provided, the GraphCountNodesDegree will be called. 
% Returns:
%   Hierarchy   -    structure          -   Contains the information, sufficient for any type of Hierarchy analysis based on this algorithm
%
% Algorithm:
%   1. Compute node degree: D
%   2. Compute node betweenness centrality: B
%   3. For each pair of nodes compute: Difference of Hij = Bi/Di-Bj/Dj.  
%
% Properties:
%   Hij = -Hji
%   Hij>0, i higher then j. 
%
% See Also:
%  mexGraphBetweennessCentrality
%		
% Examples:
%  [ Hierarchy ] = GraphBetweennessDegreeHierarchy(Graph);
%
%       or
%
%  [BetweennessCentrality, Nodes] = mexGraphBetweennessCentrality(DLLGraph,[],'direct',1);
%  [ Hierarchy ] = GraphBetweennessDegreeHierarchy(Graph,'Betweenness',BetweennessCentrality,'Nodes',Nodes )
%
%       or
%
%  [BetweennessCentrality, Nodes] = mexGraphBetweennessCentrality(DLLGraph,[],'direct',1);
%  Degrees = GraphCountNodesDegree(Graph);
%  Degrees = Degrees(:,3);
%  [ Hierarchy ] = GraphBetweennessDegreeHierarchy(Graph,'Betweenness',BetweennessCentrality,'Nodes',Nodes,'Degrees',Degrees);
% 

error(nargchk(0,inf,nargin));
error(nargoutchk(0,1,nargout));

if ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end

if isempty(Betweenness)
    [Betweenness, Nodes] = mexGraphBetweennessCentrality(DLLGraph,Nodex,'direct',1);
end
if isempty(Nodes)
    Nodes = GraphNodeIDs(Graph);
end

if isempty(Degrees)
    Degrees = GraphCountNodesDegree(Graph);
    Degrees = Degrees(Nodes,3);
end

Hierarchy = [];
Hierarchy.Nodes = Nodes;
Hierarchy.Betweenness = Betweenness;
Hierarchy.Degree = Degrees;
%Hierarchy.HierarchyMapNodesI = zeros(numel(Nodes),numel(Nodes));
%Hierarchy.HierarchyMapNodesJ = zeros(numel(Nodes),numel(Nodes));
Hierarchy.HierarchyMap = zeros(numel(Nodes),numel(Nodes));
for Node = Nodes(:).'
    index = find(Nodes == Node);
    Hierarchy.HierarchyMap(index,:)= Betweenness(Node)*Degrees(Node)-Betweenness(Nodes).*Degrees(Nodes);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput
DefaultInput = {};
DefaultInput    =   FIOAddParameter(DefaultInput,'Nodes',[]);
DefaultInput    =   FIOAddParameter(DefaultInput,'Betweenness',[]);
DefaultInput    =   FIOAddParameter(DefaultInput,'Degrees',[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%