function [ adjList ] = createAdjList( adj, varargin )
%CREATEADJLIST Convert an adjacency matrix to an adjacency list
%   Not called currently by any function

p = inputParser;

validTypes = {'BD','UD','Bipartite'};

p.addRequired('adj',@isnumeric);
p.addOptional('adjType','BD',@(x) any(validatestring(x,validTypes)));

p.parse(adj,varargin{:});
opts = p.Results;
adjType = opts.adjType;

% Validate input
if ~strcmp(adjType,'Bipartite')
    assert(size(adj,1)==size(adj,2),'Input matrix does not describe a bipartite graph and is not rectangular');
end
if strcmp(adjType,'UD')
    if ~issymmetric(adj) ||...
       nnz(tril(adj)) ||...
       nnz(triu(adj))
        error('Input matrix specified unidirectional but directed edges provided');
    end
end

% Allocate cell array
if strcmp(adjType,'Bipartite')
    adjList = cell(size(adj,1)+size(adj,2),1);
else
    adjList = cell(size(adj,1),1);
end

% Parse and convert input
switch adjType
    case 'BD' % Directed graph
        for i=1:size(adj,1)
            adjList{i} = find(adj(i,:));
        end
    case 'UD' % Undirected graph
        for i=1:size(adj,1)
            adjList{i} = find(adj(i,:));
            for j=adjList{i}
                adjList{j}=sort([adjList{j} i]);
            end
        end
    case 'Bipartite' % Bipartite graph
        offset = size(adj,1);
        for i=1:size(adj,1)
            adjList{i} = find(adj(i,:))+offset;
            for j=adjList{i}
                adjList{j}=sort([adjList{j} i]);
            end
        end
end

end

