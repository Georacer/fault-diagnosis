function Graph = GraphLoadFromFile(FileName)
% Loads Graph from Mat-file
%
% Receives:
%   FileName    -   string                      -   the name if the file to store the data to. If the file exists, it is overwritten
%
% Returns:
%   Graph       -   Graph Struct                -   the graph or empty struct.
%

error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

try
    if exist(FileName,'file')==2
        load(FileName,'Graph','-mat');
        if ~ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs')
            Graph = [];
        end
    else
        Graph = [];
    end
catch
    Graph = [];
end
