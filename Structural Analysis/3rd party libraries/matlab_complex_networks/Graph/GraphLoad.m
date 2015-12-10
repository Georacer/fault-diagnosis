function [Graph,varargout] = GraphLoad(FileName,IndexFileName,SkipSqueeze,varargin)
% Loads a graph from file
%
% Receives:
%   FileName        -   string              -   the file to load
%                       Nx2 of integers     -   the actual links
%   IndexFileName   -   string  -   (optional) the name of the file which holds the index, The index file must
%                                   comply with the following format: 2 columns. For each node it's name (string) 
%                                   and index are provided. Default: [].
%                       -   structure   - The structure containing the index
%                               .IndexNames -   vector of integers  -   lists node indeces
%                               .IndexValues-   cell str            -   lists appropreate names
%                       -   cell 2x1 or 1x2 -   Cell containing the index, where the first cell is indeces, while the second - their names
%   SkipSqueeze     -       boolean -   (optional) If true (~=0), the mexGraphSqueeze function is not called after the graph is loaded. Default: 0
%   varargin            -       FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                               Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                               IndexFileImportHandle   |   function pointer|   Yes         |   @(IndexFileName)textread(IndexFileName,'%s %d');       | Defines how the index file is read.
%
% Returns:
%       Graph               -   Graph Struct -   the loaded graph
%		LUT             -	Nx2 of integers	-	(optional)  Look up table of the size Nx2 (N - number of nodes in the graph) with the 
%                                                                           order in which the node's numbering was changed. Can be used for corresponding ordering 
%                                                                           of other node parameters.    See 'mexGraphSqueeze'
%

error(nargchk(1,inf,nargin));
error(nargoutchk(0,2,nargout));

if ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end

if ~exist('IndexFileName','var')
    IndexFileName = '';
end

if ~exist('SkipSqueeze','var')
    SkipSqueeze = 0;
end

IndexNames = [];
IndexValues = [];
if ischar(FileName)
    LinksData = load(FileName,'-ascii');
    Graph.FileName = FileName;
else
    LinksData  = FileName;
    FileName = '';
end
if ischar(IndexFileName) && exist(IndexFileName,'file')
    try
        [IndexValues IndexNames] = textread(IndexFileName,'%d %s');
        %[IndexNames IndexValues] = IndexFileImportHandle(IndexFileName);
    catch
    end
elseif isstruct(IndexFileName)
    IndexNames  = IndexFileName.IndexNames;
    IndexValues = IndexFileName.IndexValues;
elseif iscell(IndexFileName) && numel(IndexFileName)==2
    IndexNames  = IndexFileName{1};
    IndexValues = IndexFileName{2};
end
if nargout < 2
    Graph = ObjectCreateGraph(LinksData,mfilename,'IndexNames',IndexNames,'IndexValues',IndexValues,'SkipSqueeze',SkipSqueeze);
else
    [Graph varargout{1}]= ObjectCreateGraph(LinksData,mfilename,'IndexNames',IndexNames,'IndexValues',IndexValues,'SkipSqueeze',SkipSqueeze);
end    
Graph.FileName = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput
DefaultInput = {};

DefaultInput    =   FIOAddParameter(DefaultInput,'IndexFileImportHandle',@(IndexFileName)textread(IndexFileName,'%s %d')); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

