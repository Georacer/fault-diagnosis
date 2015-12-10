function Graph = GraphLoadAdjacencyMatrixFromFile(FileName)
% Loads Graph from ASCII file containing adjacency matrix.
%
% the file should contain the matrix 'wrapped' with node ids as first ran and first column and
% having 0 in place of missing links, an weights (wij) in places corresponding to weighted links.
%
% Receives:
%   FileName    -   string                      -   the name if the file containing the data
%
% Returns:
%   Graph       -   Graph Struct                -   the graph or empty struct.
%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

try
    if exist(FileName,'file')==2
        RawData = load(FileName,'-ascii');
        %         GraphData = RawData(2:end,2:end);
        IndexM = RawData(2:end,1); IndexN = RawData(1,2:end);
        [i, j] = find(RawData(2:end,2:end));
        %         Weights = RawData((i+1)+j*size(RawData,1));
        Links = [RawData(i+1,1) RawData(1,j+1).' RawData((i+1)+j*size(RawData,1))];
        Links(Links(:,1)==Links(:,2),:) = [];
        Graph = GraphLoad(Links,'',1);
        [~, SO] = sort(Graph.Data(:,1)+max(max(Graph.Data(:,1:2)+1))*Graph.Data(:,2));
        Graph.Data = Graph.Data(SO,:);        
    else
        Graph = [];
    end
catch
    Graph = [];
end