function Distribution = GraphNodeDistancesDistribution(Graph,MaxSearchDistance, NodeIDs,Direction)
% Returns average number of nodes at the specified distance from each of the provided Nodes.
%
% Receives:
%       Graph                           -   Graph Struct            -   the graph loaded with GraphLoad
%       MaxSearchDistance               -       integer, >0         -   (optiona) The maximal distance to search. The distribution is computed up to this distance. (Dealaut)-inf,
%       NodeIDs                         -     vector of integers    -   (optional) list of nodes. For each of them number of neighbours is computed at each distance.  Default - [].
%	    Direction                       -	string                  -	(optional) Either 'direct' or 'inverse'. Case insensitive. The incoming or outgoing links are 
%                                                                                 followed as a function of this parameter. Default: 'direct'
% Returns:
%      Distance                        -      integer               -   Length of the shortest path between the nodes. -1 if they are not connected or the path is longer then    MaxSearchDistance
% See Also:
%       GraphLoad, mexNodeSurroundings
%



error(nargchk(1,4,nargin));
error(nargoutchk(0,1,nargout));

ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');

if ~exist('MaxSearchDistance','var')
    MaxSearchDistance = inf;
end
if ~exist('Direction','var')
        Direction = 'direct';
end

if ~exist('NodeIDs','var') | isempty(NodeIDs)
    NodeIDs = unique(Graph.Data(:,1:2));
end

if MaxSearchDistance >  size(Graph.Data,1);
    MaxSearchDistance = size(Graph.Data,1);
end
Neightbours = mexNodeSurroundings(Graph,NodeIDs,MaxSearchDistance, Direction);

if numel(NodeIDs)==1
    Distribution = zeros(size(Neightbours));
    i = 1;
   while i <= numel(Neightbours)  & numel(Neightbours{i}) ~=0
        Distribution(i) = numel(Neightbours{i});
        i = i + 1;
    end
else
    Distribution = zeros(size(Neightbours{1}));
    for Node = 1 : numel(Neightbours)
        i = 1;
        while i <= numel(Neightbours{Node})   & numel(Neightbours{Node}{i}) ~=0
                Distribution(i) = Distribution(i) + numel(Neightbours{Node}{i});
                i  = i +1;
        end        
    end      
end

if Distribution(1) 
    Distribution = Distribution/Distribution(1);
end

Indeces = find(Distribution~=0);
if ~isempty(Indeces) & Indeces(end) < numel(Distribution)
    Distribution = Distribution(1:Indeces(end)+1);
end
