function Graph  = GraphConvertFromV2(Graph)
% Converts the Graph structure from V2 of the toolbox to V1. Links, weights, index and properties are converted. Up to 50% more space is requires.
%
% Receives:
%   Graph       -   Graph Struct                                -   the graph structure which can be used with any function of V2 of the toolbox.
%   
% Returns:
%   Graph       -   Graph Struct                                -   the graph structure compatible with the V1 of the Toolbox
%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

if isfield(Graph,'Version') & Graph.Version==2
    if isempty(Graph.Weights) | numel(Graph.Weights)~=size(Graph.Data,1)
      Graph.Data = [double(Graph.Data) ones(size(Graph.Data,1),1)];
    else
        Graph.Data = [double(Graph.Data) Graph.Weights];
    end
    Graph.Index.Values = double(Graph.Index.Values);

    for i = 1 : numel(Graph.Index.Properties)
        Graph.Index.Properties(i).NodeIDs = double(Graph.Index.Properties(i).NodeIDs);
    end
    Graph.Version = 1;
end