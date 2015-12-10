function Graph= GraphGenerateSquareLattice(m,n)
% Creates a graph representing square lattice of size mxn. The total number of nodes: N=m*n. Ties: |E| = 4*N
% in the graph, every nodes has a degree of 4. A node s is located at coordinates (i = s-(j-1)*m, j = floor(s/m)+1).
% is linked to nodes (i-1,j), (i, j-1), (i+1, j), (i, j+1). Nodes at the boundary are tied to the appropriate nodes at the other side (circular boundary conditions).
%   
% Receives:
%   m - scalar, integer - number of lattice rows. 
%   n - scalar, integer - number of lattice columns. 
%   
% Returns:
%   Graph - struct - created with ObjectCreateGraph
%
% Example:
%   Graph = GraphGenerateSquareLattice(10,10);
%
% See Also:
%       GraphLoad
%


error(nargchk(2,2,nargin));
error(nargoutchk(0,2,nargout));
Links = zeros(4*m*n, 3);
NodeIDs = 1 : m*n;
js = 1+floor( (NodeIDs-1) /m);
is = NodeIDs-(js-1)*m;
Links(:,1) = reshape(repmat(1:m*n,4,1),4*m*n,1);
Indeces = 1 : 4 : 4*m*n; 

Links(Indeces ,2) = is+(js-2)*m; % left
Links(Indeces+1 ,2) = is-1+(js-1)*m; % up
Links(Indeces+2 ,2) = is+1+(js-1)*m; % down
Links(Indeces+3 ,2) = is+js*m; % right

% circular boundary conditions
Links(Indeces(js==1) ,2) = is(js==1)+(n-1)*m; 
Links(Indeces(is==1)+1 ,2) = m+(js(is==1)-1)*m;
Links(Indeces(is==m)+2 ,2) = 1+(js(is==m)-1)*m;
Links(Indeces(js==n)+3 ,2) = is(js==n)+(1-1)*m;
% weights
Links(:,3) = 1;
Graph = ObjectCreateGraph(Links, mfilename);