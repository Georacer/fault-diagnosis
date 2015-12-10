function Success = GraphSaveAsDirectedListToFile(Graph,FileName)
% Effectively Saves the Graph to ASCII file in the format: SOURCE_NODER LIST_OF_DESTINATION_NODES
%
% Receives:
%   Graph       -   Graph Struct                -   the graph loaded with GraphLoad
%   FileName    -   string                      -   the name if the file to store the data to. If the file exists, it is overwritten
%
% Returns:
%   Success     -   boolean                     -   true (1) if succeeded, false (0) - if not
%
% Example:
%   Graph = GraphLoad('E:\Documents\Articles\Data\ColiNet\coliInterFullVec.txt ','E:\Documents\Articles\Data\ColiNet\coliInterFullNames.txt ');
%   Success = GraphSaveAsDirectedListToFile(Graph,'E:\ColiDirectedList.lst');
%
%   or:
%   Graph = GraphLoad('E:\Documents\Articles\Data\Yeast\Barabasi\bo.dat.gz');
%   Success = GraphSaveAsDirectedListToFile(Graph,'E:\bo.lst');
%

error(nargchk(2,2,nargin));
error(nargoutchk(0,1,nargout));

ObjectIsType(Graph,'Graph','The operation can only be performed on Graphs');

try
    if exist(FileName,'file')==2
        delete(FileName);
    end
    h = fopen(FileName,'wb+');
    NodeIDs = GraphNodeIDs(Graph);
    for CurrentNodeID = NodeIDs(:).'
        Indeces = find(Graph.Data(:,1)==CurrentNodeID);
        fprintf(h,'%d\t%s\n',CurrentNodeID,num2str(Graph.Data(Indeces,2).'));
    end
    fclose(h);
    Success = 1;
catch
    Success=0;
end