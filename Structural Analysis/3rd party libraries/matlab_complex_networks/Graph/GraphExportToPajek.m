function GraphExportToPajek(Graph,PajekFileName,varargin)
% Exports Graph into pajek format 
%
% Receives:
%   Graph            -   struct  -   struct, representing the graph
%   PajekFileName    -   string  -   the name of the file to store the exported graph. Will typically have a .net extension. 
%   varargin            -       FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                               Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                                   DefaultFillColor    |   string          |  yes          |  Green          | fill color of nodes. 
%                                                   DefaultBorderColor  |   string          |  yes          |  Brown          | border color of nodes. 
%                                                   FillColor           |   struct          |  yes          | []              | a struct with two fields: .ID (list of node IDs) and .Color (string representing the node fill color. I.e. "Gree", "Brown", etc. 
%                                                   BorderColor         |   struct          |  yes          | []              | a struct with two fields: .ID (list of node IDs) and .Color (string representing the node border color. I.e. "Gree", "Brown", etc. 
%                                                   DefaultEdgeColor    |   string          |  yes          |  Black          | color of edges. 
%                                                   
% Returns:
%   Nothing 
%
% See Also:
%   GraphRemoveDuplicateLinks, GraphExportToFile
%
% Notes:
%   File format: http://vw.indiana.edu/tutorials/pajek/
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% verify input
error(nargchk(2,inf,nargin));
error(nargoutchk(0,0,nargout));

if  ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end

NodeIDs = unique(Graph.Data(:,[1 2]));

NewFillColor = [];
NewFillColor.ID = NodeIDs;
NewFillColor.Color = cell(size(NodeIDs));
[isfound,ai] =ismember(NewFillColor.ID,FillColor.ID);
NewFillColor.Color(isfound) = FillColor.Color(ai(isfound));
NewFillColor.Color(~isfound) = repmat({DefaultFillColor},[nnz(~isfound) 1]);
FillColor = NewFillColor;

NewBorderColor = [];
NewBorderColor.ID = NodeIDs;
NewBorderColor.Color = cell(size(NodeIDs));
[isfound,ai] =ismember(NewBorderColor.ID,BorderColor.ID);
NewBorderColor.Color(isfound) = BorderColor.Color(ai(isfound));
NewBorderColor.Color(~isfound) = repmat({DefaultBorderColor},[nnz(~isfound) 1]); 
BorderColor = NewBorderColor;

%%open file
hFile = fopen(PajekFileName,'w+t');
if hFile==0, error(['Filed to open pajek file ''' PajekFileName]); end

%% write nodes. 
fprintf(hFile,'*Vertices %d\n',numel(NodeIDs));
for i = 1 : numel(NodeIDs)
    fprintf(hFile,'%d "%d" 0.0 0.0 0.0 ic %s bc %s\n',i,NodeIDs(i), FillColor.Color{FillColor.ID==NodeIDs(i)},BorderColor.Color{BorderColor.ID==NodeIDs(i)});
end
%% write arcs
fprintf(hFile,'*Arcs \n');
for i = 1 : size(Graph.Data,1)
    fprintf(hFile,'%d %d 1 c %s\n',find(NodeIDs==Graph.Data(i,1),1,'first'),find(NodeIDs==Graph.Data(i,2),1,'last'),DefaultEdgeColor);
end

fclose(hFile);

end % GraphExportToPajek


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set default input parameters
function DefaultInput  = GetDefaultInput
DefaultInput = {};

DefaultInput    =   FIOAddParameter(DefaultInput,'DefaultFillColor','Green'); 
DefaultInput    =   FIOAddParameter(DefaultInput,'DefaultBorderColor','Brown'); 
DefaultInput    =   FIOAddParameter(DefaultInput,'DefaultEdgeColor','Black'); 
Color = [];
Color.ID = []; Color.Color = {};
DefaultInput    =   FIOAddParameter(DefaultInput,'FillColor',Color); 
DefaultInput    =   FIOAddParameter(DefaultInput,'BorderColor',Color); 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
