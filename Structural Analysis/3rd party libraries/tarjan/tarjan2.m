function [SCC,I] = tarjan2(e)
% function SCC = tarjan(e)
% Implements tarjan's algorithm for a graph with adjacency matrix e.  A value in
% e(i,j) indicates an edge from v(j) to v(i).  If this is transposed from the
% default, well it really shouldn't matter, right? 
%
% Returns a cell array of vectors containing scc's, sorted by descending size. The
% length of SCC will equal the number of strongly connected components.  If (V,E) is
% acyclic then SCC will be an Nx1 cell array of single vertices.
%
% function [SCC,I] = tarjan(N,e)
% also returns an Nx1 vector of indices into SCC corresponding to nodes in v.
%
% Usage example:
% >> E = sparse([2 3 4 5 5 6 6 7 8 4 9 5 10 6 9], ...
% [1 2 2 3 4 3 5 6 4 8 8 9 9 10 6], ...
% ones(1,15));
% >> c = tarjan(E)
% c = 
%     [1x4 double]    [1x2 double]    [7]    [3]    [2]    [1]
% >> c{1}
% ans =
%      5     6     9    10
% >> 
% >> 
%
% Here E is the adjacency matrix for a directed graph, and the nodes with indices
% 5, 6, 9, and 10 form the largest strongly connected component in the graph.
%
% Taken from: https://www.mathworks.com/matlabcentral/fileexchange/50707-tarjan-e-


% using globals because matlab doesn't have shared private variables
global tarjan_v tarjan_SCC tarjan_stack index

tarjan_SCC={};
tarjan_stack=[];

N=max(size(e));

tarjan_v = struct('index',num2cell(zeros(1,N)),'lowlink',num2cell(zeros(1,N)), ...
                  'onStack',num2cell(logical(zeros(1,N))));

index=0;

% loop through all nodes
for i=1:N
    if tarjan_v(i).index==0
        strongconnect(i,e);
    end
end

% generate count vector
for j=1:length(tarjan_SCC)
    count(j)=length(tarjan_SCC{j});
    tarjan_SCC{j}=sort(tarjan_SCC{j}); % for convenience- sort individual components
end

% sort by decreasing size
[~,q]=sort(count,'descend');
SCC=tarjan_SCC(q);

for j=1:length(SCC)
    I(SCC{j})=j;
end


function strongconnect(i,e)
global tarjan_v tarjan_SCC tarjan_stack index
index=index+1;

% visit the node
tarjan_v(i).index=index;
tarjan_v(i).lowlink=index;
tarjan_stack=[i tarjan_stack];
tarjan_v(i).onStack=true;

if size(e,2)>=i
    out_edges=find(e(:,i));
else % permit operation on rectangular matrices
    out_edges=[];
end

for k=1:length(out_edges)
    j=out_edges(k);
    % if not visited, visit
    if tarjan_v(j).index==0
        strongconnect(j,e);
        % carry back lowlink, if lower
        tarjan_v(i).lowlink=min(tarjan_v([i j]).lowlink);
    elseif tarjan_v(j).onStack==true
        % carry back index, if lower
        tarjan_v(i).lowlink=min([tarjan_v(i).lowlink tarjan_v(j).index]);
    end
end

if tarjan_v(i).lowlink == tarjan_v(i).index
    % label a new SCC
    theSCC=tarjan_stack(1:find(tarjan_stack==i));
    tarjan_stack=tarjan_stack(length(theSCC)+1:end);
    [tarjan_v(theSCC).onStack]=deal(false);
    tarjan_SCC=[tarjan_SCC {theSCC}];
end
