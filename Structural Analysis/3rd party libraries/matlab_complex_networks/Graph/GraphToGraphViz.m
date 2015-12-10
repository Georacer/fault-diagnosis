function DotFileName = GraphToGraphViz(Graph, DotFileName,varargin )
% Uses AT&T GraphViz to plot the graph
%
% Receieves:
%   Graph           -   graph struct    -   Graph, loaded with LoadGraph and/or created with ObjectCreateGraph
%   DotFileName    -   string           -   A path to the file in GraphViz DOT format
%   varargin        -   FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                       Parameter Name          |  Type         |  Optional |   Default Value |   Description
%                                           Directional         |   bool        |    yes    |   1             | specifies wheather the graph is directional or not  
%
%
%
%
% Returns:
%   DotFileName - string  - the file name where the graph is stored. 
%
% See Also:
%   ObjectCreateGraph,LoadGraph,
%   
% 
% Example:
%   GraphDrawGraphViz(Graph,'Graph.DOT','Directional',1);


error(nargchk(2,inf,nargin));
error(nargoutchk(0,1,nargout));

if ~FIOProcessInputParameters(GetDefaultInput)
    error('The default input is not FlexIO compatible');
end
if ~FIOProcessInputParameters(varargin)
    error('The input is not FlexIO compatible');
end

DOT = {};
if Directional
    DOT{end+1} = 'digraph G {';
else
    DOT{end+1} = 'graph G {';
end

if isfield(Graph,'Index') && ~isempty(Graph.Index.Values)
    DOT{end+1} = [ '// Nodes start'];
    for Node = 1 : numel(Graph.Index.Values)
        DOT{end+1} = [ num2str(Graph.Index.Values(Node)) ' [label="' Graph.Index.Names{Node} '" shape=circle ];'];        % ellipse
    end
    DOT{end+1} = [ '// Nodes end'];
end
DOT{end+1} = [ '// Links start'];
for Link = 1 : size(Graph.Data,1)
   DOT{end+1} = [ num2str(  Graph.Data(Link,1) ) ' -> ' num2str(  Graph.Data(Link,2) ) ';' ];
end
DOT{end+1} = [ '// Links end'];

DOT{end+1} = '}  //graph'; 

% if ~isempty(GraphVizPath) && GraphVizPath(end)~='\'
%     GraphVizPath(end+1) = '\';
% end

% TempFileName = [GraphVizPath 'Graph.dot'];
h = fopen(DotFileName,'w+t');
for i = 1 : numel(DOT)
   fprintf(h,'%s\n',[DOT{i}]);
end
fclose(h);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput()
DefaultInput = {};

% DefaultInput    =   FIOAddParameter(DefaultInput,'NumberOfBins',15);
DefaultInput    =   FIOAddParameter(DefaultInput,'Directional',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %{
digraph g {
"start" [ label = "MWGC-" ];
"n1" [ label = "WC-MG" ];
"n2" [ label = "MWC-G" ];
"n3" [ label = "C-MWG" ];
"n4" [ label = "W-MGC" ];
"n5" [ label = "MGC-W" ];
"n6" [ label = "MWG-C" ];
"n7" [ label = "G-MWC" ];
"n8" [ label = "MG-WC" ];
"n9" [ label = "-MWGC" ];
"start" -> "n1" [ label = "g" ];
"n1" -> "start" [ label = "g" ];
subgraph l { rank = same; "n3" "n4" }
subgraph r { rank = same; "n5" "n6" }
"n1" -> "n2" [ label = "m" ];
"n2" -> "n1" [ label = "m" ];
"n2" -> "n3" [ label = "w" ];
"n3" -> "n2" [ label = "w" ];
"n2" -> "n4" [ label = "c" ];
"n4" -> "n2" [ label = "c" ];
"n3" -> "n5" [ label = "g" ];
"n5" -> "n3" [ label = "g" ];
"n4" -> "n6" [ label = "g" ];
"n6" -> "n4" [ label = "g" ];
"n5" -> "n7" [ label = "c" ];
"n7" -> "n5" [ label = "c" ];
"n6" -> "n7" [ label = "w" ];
"n7" -> "n6" [ label = "w" ];
"n7" -> "n8" [ label = "m" ];
"n8" -> "n7" [ label = "m" ];
"n8" -> "n9" [ label = "g" ];
"n9" -> "n8" [ label = "g" ];
} 
%}