function [GraphLinksIndeces, varargout] = GraphLinkFind(Graph,Links)
% Find a link or  list of links indeces on the graph. For each found link its index in the graph matrix is returned..
%
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%   Lists       -   vector   Nx2 or Nx3                      -   list of links to be removed from the graph. Each links is a 1x2 vector of the source and destination node. The link must not 
%                                                                                        exist on the graph. If Nx3 list is provided, the weights are ignored.
%
% Returns:
%   GraphLinksIndeces -   vector Kx1                           - List of indeces for those of the provided link which where found.
%   
%
% See Also:
%       GraphLoad,
%
% Changes:
%
%	Dmitri Krioukov
% 		- Empty graphs are properly handled
%		- proper parameter initialization

error(nargchk(2,2,nargin));
error(nargoutchk(0,2,nargout));

ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');

GraphLinksIndeces  = [];
 
if isempty(Links) || isempty(Graph.Data) 
	if nargout>1,  varargout{1} = []; end
	return; 
elseif ~any(size(Links,2)~=[2 3]) &  error('List of links must be of size Nx2 or Nx3'); end
PowerFactor = 10^(-ceil(log10(max(Graph.Data(:))))-1);

GraphLinks = Graph.Data(:,1)+PowerFactor *Graph.Data(:,2);
RemoveLinks = Links(:,1)+PowerFactor *Links(:,2);
[GraphLinks GraphLinksIndeces LinkeIndeces]= intersect(GraphLinks,RemoveLinks);

if nargout>1
    varargout{1} = LinkeIndeces;
end
%Graph .Data =Graph.Data(GraphLinksIndeces,:);
 
%Graph =  mexGraphSqueeze(Graph);