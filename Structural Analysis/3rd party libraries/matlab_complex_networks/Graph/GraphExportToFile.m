function GraphExportToFile(Graph,FileName,varargin)
% Exports Graph into file for use outside the toolbox
%
% Receives:
%   Graph       -   struct  -   struct, representing the graph
%   FileName    -   string  -   the name of the file to store the exported graph
%   varargin            -       FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                               Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                                   Separator           |   string          |   Yes         |   '\t'          |   separates output values in file
%                                                   EnsureUniqueLinks   |   boolean         |   Yes         |    1 (true)     | If true, 'GraphRemoveDuplicateLinks' is called
%                                                   Triangular          |   boolean         |   Yes         |    0 (false)    | If true, only links (i,j) where i<j are exported
%                                                   Format              |   string          |   Yes         |   'links'       | Case insensitive. Can be 'links' (produces list of links) or 
%                                                                                                                               'list' - list of linked nodes for each node.
%
%
%
%
%
%
%
%
%
% Returns:
%   Nothing 
%
% See Also:
%   GraphRemoveDuplicateLinks, PajekFileName
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% varify input
error(nargchk(1,inf,nargin));
error(nargoutchk(0,0,nargout));

if ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end

%% precompute
if EnsureUniqueLinks
    Graph = GraphRemoveDuplicateLinks(Graph);
end
if Triangular
   Indeces = find(Graph.Data(:,1)>=Graph.Data(:,2));
   Graph.Data(Indeces,:) = [];
end

%% export
h = fopen(FileName,'wt');
try
    switch lower(Format)
        case 'links'            
            for i = 1 : size(Graph.Data,1)
                fprintf(h,['%d' Separator '%d\n'],Graph.Data(i,1),Graph.Data(i,2));
            end
        case 'list'
            MaxNode = max(max(Graph.Data(:,1:2)));
            for i = 1 : MaxNode
                fprintf(h,['%d'],i);
                Targets = find(Graph.Data(:,1)==i);
                for j = 1 : numel(Targets)
                    fprintf(h,[Separator '%d'],Targets(j));
                end
                fprintf(h,'\n');
            end
    end    
catch
   disp(['Fatal Error: ' lasterr]); 
end

fclose(h);
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set default input parameters
function DefaultInput  = GetDefaultInput
DefaultInput = {};

DefaultInput    =   FIOAddParameter(DefaultInput,'Separator','\t'); 
DefaultInput    =   FIOAddParameter(DefaultInput,'EnsureUniqueLinks',1); 
DefaultInput    =   FIOAddParameter(DefaultInput,'Triangular',0); 
DefaultInput    =   FIOAddParameter(DefaultInput,'Format','links'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


