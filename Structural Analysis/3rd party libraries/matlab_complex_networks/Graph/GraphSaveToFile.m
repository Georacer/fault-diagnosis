function Success = GraphSaveToFile(Graph,FileName)
% Saves the Graph to Mat-file
%
% Receives:
%   Graph       -   Graph Struct                -   the graph loaded with GraphLoad
%   FileName    -   string                      -   the name if the file to store the data to. If the file exists, it is overwritten
%
% Returns:
%   Success     -   boolean                     -   true (1) if succeeded, false (0) - if not
%

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));

ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');

try
    if exist(FileName,'file')==2
        delete(FileName);
    end
    save(FileName,'Graph','-mat');
    Success = 1;
catch
    Success=0;
end