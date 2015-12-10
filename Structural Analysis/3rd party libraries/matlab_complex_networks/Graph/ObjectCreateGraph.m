function [Graph, varargout]= ObjectCreateGraph(LinksData,Signature,varargin)
% Creats a standatized object representing general two-directional Graph
%   
% Receives:
%       LinksData      -    matrix Nx2   -   (optional) List of N directed links. Each link is weighted equally
%                           matrix Nx3  -   List of N directed links. Each link is weighted by the value in the 3'rd column
%                                           default: [].    
%       Signature       -     string         -   (optional)  The name of the function wich processes the Data. If FlexIO is used, Signature must be defined.
%       varargin        -   FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                       Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                          Type                 |  string           |   no          |          -                       |   The data struct type name 
%                                           IndexNames          |   cells array of strings   | yes  |       {}        |   USED by graph toolbox. IndexNames & IndexValues define a LUT and 
%                                           IndexValues         |   array of integers | yes         |       []        |   is used as index to identify each node with some real object: IP, DLL, etc.
%                                           FileName            |   string          |   yes         |       ''        |  the name of the file from which the data was loaded
%                                           SkipSqueeze         |   boolean         |   yes         |       0         | If true (!=0), the mexGraphSqueeze is not called after the graph is loaded.
%
%       
%   
%
% Returns:
%       Graph        -    struct     -    Created with ObjectCreate. Type: 'Graph' Also contains 1 additional field: .Data
%		LUT             -	Nx2 of integers	-	(optional)  Look up table of the size Nx2 (N - number of nodes in the graph) with the 
%                                                                           order in which the node's numbering was changed. Can be used for corresponding ordering 
%                                                                           of other node parameters.    See 'mexGraphSqueeze'
%
% See Also:
%   ObjectCreate, mexGraphSqueeze
%
% Example:
%   Graph = ObjectCreateDataSeries(Data);
%   
%
% Major Changes:
%   The function now support Index. Two new parameters are supported in function call: IndexNames & IndexValues
%
% Major Changes:
%   Can accept empty input ([]) as a list of nodes. In this case, an empty Graph is returned. Can be useful, if the user 
%   wishes to populate the graph manualy.
%
% Major Changes:
%   Another field was added: FileName
%
% Major Changes:
%   Another field was added: SkipSqueeze
%
% Major Changes:
%	LUT parameter added.

error(nargchk(0,inf,nargin));
error(nargoutchk(0,2,nargout));

if ~exist('LinksData','var') | isempty(LinksData)
    LinksData = zeros(0,3);
end
    
if ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end

if exist('Signature','var')
    Signature = {mfilename,Signature};
else
    Signature = mfilename;
end
if ~isnumeric(LinksData) | size(LinksData,2)<2 | size(LinksData,2)>3
    error('The links are not in proper format');
end

Graph = ObjectCreate('Type','Graph','Signature',Signature);
Graph.FileName = '';

if size(LinksData,2)==2
    LinksData = [LinksData ones(size(LinksData,1),1)];
end
Graph.Data   =   LinksData;
if exist('IndexNames','var') & exist('IndexValues','var') & ndims(IndexValues)==ndims(IndexNames) & all(size(IndexValues)==size(IndexNames) & ~isempty(IndexValues))
    Index.Exist  = 1;
    Index.Names  = IndexNames;
    Index.Values = IndexValues;   
end
Graph.Index = Index;

if ~SkipSqueeze & nargin < 2
    Graph = mexGraphSqueeze(Graph);
elseif ~SkipSqueeze
    [Graph varargout{1}]= mexGraphSqueeze(Graph);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput
DefaultInput = {};

Index           =   [];
Index.Names     =   {};,
Index.Values    =   [];
Index.Exist     =   0;
Index.Properties = [];
DefaultInput    =   FIOAddParameter(DefaultInput,'Index',Index);
DefaultInput    =   FIOAddParameter(DefaultInput,'FileName','');
DefaultInput    =   FIOAddParameter(DefaultInput,'SkipSqueeze',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

