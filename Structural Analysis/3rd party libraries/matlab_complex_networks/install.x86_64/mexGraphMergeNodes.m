function [Links varargout]= mexGraphNodes(Graph, RedirectionList)
% Redirects links in 'Graph' from each node in column 1 of 'RedirectionList' to the corresponding node of the column 2.
% Multiple redirections are supported (ex. 1->2, 2->3, 3->4 => 1->4).
% 
% Receives:
%   Graph             -   struct      -   Graph created with GraphLoad or ObjectCreateGraph
%						  Nx2 or Nx3 of IDs  -   List of links. Can be used to split huge graphs into smaller components.
%   RedirectionList   -   matrix Nx2  -   Matrix of Node IDs. All links to/from nodes in first columns are redirected to correcponding
%                                         node in column 2. Eventually, no links will point at nodes in col.1. Each node in col. 1 will
%                                         point at the corresonding node at col. 2.
% 
% Returns:
%   Links           -   matrix Mx3		-  List of links with weights (all weights are set to 1). 
%	RedirectionList	-	matrix Nx2		-	(optional) The final list of redirections. Built from the original 'RedirectionList' via relaxation.
% 
% Algorithm:
%   Run time: O(M*N).
%
% See Also:
%   WikiRelaxRedirects
%
% Major Updates:
%	Optional 'RedirectionList' parameter added to the method output.
%
% Major Updates:
%   Graph can now be a matrix with a list of links.	
