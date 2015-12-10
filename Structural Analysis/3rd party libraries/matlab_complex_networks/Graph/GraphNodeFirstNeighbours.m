function Neighbours = GraphNodeFirstNeighbours(Graph,RootNode,Direction)
% Returns list of neighbour node IDs
%
% Receive:
%	Graph		-	Graph Struct	-	Struct created with ObjectCreateGraph function (probanly called by GraphLoad).
%	NodeID		-	integer			-	the ID of the node for whitch the neighbours are searched.creas with the distance dramatically
%	Direction	-	string			-	(optional) Either 'direct' or 'inverse'. Case insensitive. The incoming or outgoing links are 
%										followed as a function of this parameter. Default: 'direct'
%
% Returns: 
%	Neightbours	-	vector (Nx1)	-	If NodeID is scalar, a vector of node IDs is returned, An edge (RootNode,Neightbours(i)) or (Neightbours(i),RootNode) or both exist.
% 
% See Also:
%	ObjectCreateGraph , GraphLoad
%																										

%% Parameters & Connection setup
error(nargchk(2,3,nargin));
error(nargoutchk(0,1,nargout));

if ~exist('Direction','var')
    Direction = 'direct';
end
switch lower(Direction)
    case 'direct'
        Indeces = find(Graph.Data(:,1)==RootNode);
        Neighbours = Graph.Data(Indeces,2);
    case 'inverse'
        Indeces = find(Graph.Data(:,2)==RootNode);
        Neighbours = Graph.Data(Indeces,1);
    case 'both'
        In= GraphNodeFirstNeighbours(Graph,RootNode,'inverse');
        Out= GraphNodeFirstNeighbours(Graph,RootNode,'direct');
        Neighbours = union(In,Out);        
end