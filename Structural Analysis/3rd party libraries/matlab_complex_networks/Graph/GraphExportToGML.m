function GraphExportToGML(Graph,FileName,varargin)
% Exports the graph into GraphML file
%
% Receives:
%       Graph           -   Graph Struct        -   the graph loaded with 
%       FileName        -   string              -   The file name. The file is overriden
%       varargin        -   FLEX IO             -   The input is in FlexIO format.  The following parameters are allowed:
%                                       Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                          Directionality       |   boolean         | yes           |       1         |   If set to 0, the graph will not be directional. controls <graph id="G" edgedefault="directed">
%                                          Colormap             |   Kx3, K is usually 64 |  yes     |   colormap      |   List of RGB colors used to color nodes and links.
%                                          NodeIDs              |   Nx1 or 1xN, ints|  yes          |   []            |   Ids of  nodes. Index into this array is used for entries into NodesColor vector. Default - [] (GraphNodeIDs is used)
%                                          NodeColors           |   Nx1 or 1xN, ints or doubles |  yes          |    []           |   Indeces into the Colormap. If not provided, the node color will not be specified. Othervize, each node will be colored according to the color in the Colormap. Nodes IDs are given in NodeIDs. If all colors are 0..1 they are scaled to be 1:K
%                                          EdgeColor            |   Mx1 or 1xK, ints or doubles |  yes          |    []           |   Indeces into Colormap vector. M - equals to the number of links in Graph or 0. Each link will be colored with the color corresponding to the color index at the appropreate location. If all colors are 0..1 they are scaled to be 1:K
%                                          NodeShapesList       |   cell string     |  yes          |    {}           |   Look up table of shape names. Default: {'hexagon','diamond','Parallelogram','Octagon','Ellipse','Trapezoid','Rectangle 3D','Round Rect','Trapezoid 2','triangle','rectangle'}.
%                                          NodeShapes           |   Nx1 or 1xN, ints|  yes          |    []           |   Indeces of values in NodeShapesList. For each node its shape may be provided.
%
% Returns:
%   None
%
% See Also:
%
% Reference:
%   http://graphml.graphdrawing.org/primer/graphml-primer.html
%   http://graphml.graphdrawing.org/specification.html
%
% Example:
%   Graph = GraphLoad('E:\Documents\Articles\Data\ColiNet\coliInterFullVec.txt','E:\Documents\Articles\Data\ColiNet\coliInterFullNames.txt');
%   GraphExportToGML(Graph,'E:\E.Coli.graphml')
%
%   or
%
%   Graph = ObjectCreateGraph([ [1 2]; [2 3]; [3 2]], 'Test','IndexNames',{'111','222','333'},'IndexValues',[1 2 3]);
%   GraphExportToGML(Graph,'c:\graph.graphml','NodeColors',rand(1,GraphCountNumberOfNodes(Graph)))
%   GraphExportToGML(Graph,'c:\graph.graphml','NodeColors',rand(1,GraphCountNumberOfNodes(Graph)),'NodeShapes',rand(1,GraphCountNumberOfNodes(Graph)),'EdgeColor',rand(1,GraphCountNumberOfLinks(Graph)))
%
%
% The function now supports FlexIO with the following parameteres: Directionality, Colormap, NodeIDs,NodeColors, EdgeColors, NodeShapesList and NodeShapes
% Varified with yEd 2.4.2.2

error(nargchk(2,inf,nargin));
error(nargoutchk(0,1,nargout));

if ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end


if exist(FileName,'file')
    delete (FileName);
end
Degrees = GraphCountNodesDegree(Graph);
if isempty(NodeIDs)
    NodeIDs = GraphNodeIDs(Graph);
end
if isempty(NodeShapesList)
    NodeShapesList = {'Rectangle'};
end
if isempty(NodeShapes) 
   NodeShapes =  zeros(size(NodeIDs));
   NodeShapes(:) = numel(NodeShapesList);
end
if all(NodeShapes>= 0) && all(NodeShapes<=1)
    NodeShapes = round(NodeShapes*(numel(NodeShapesList)-1)+1);
end
if isempty(NodeColors)
    NodeColors = zeros(size(NodeIDs));
    NodeColors(:) = ceil( size(Colormap,1)/2);
end
if all(NodeColors>= 0) && all(NodeColors<=1)
    NodeColors = round(NodeColors*(size(Colormap,1)-1)+1);
end
if isempty(EdgeColor)
    EdgeColor = zeros(GraphCountNumberOfLinks(Graph),1);
    EdgeColor(:) = ceil( size(Colormap,1)/2);
end

if all(EdgeColor>= 0) && all(EdgeColor<=1)
    EdgeColor = round(EdgeColor*(size(Colormap,1)-1)+1);
end

%% Generate the graph
GraphDocument = com.mathworks.xml.XMLUtils.createDocument('graphml');
docRootNode = GraphDocument.getDocumentElement;
%{ 
% STANDARD: http://graphml.graphdrawing.org/primer/graphml-primer.html
docRootNode.setAttribute('xmlns','http://graphml.graphdrawing.org/xmlns');
docRootNode.setAttributeNS('xmlns','xsi','http://www.w3.org/2001/XMLSchema-instance');
docRootNode.setAttributeNS('xmlns','schemaLocation','http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd');
%}
% yWorks yEd
docRootNode.setAttribute('xmlns','http://graphml.graphdrawing.org/xmlns/graphml');
docRootNode.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
docRootNode.setAttribute('xsi:schemaLocation','http://graphml.graphdrawing.org/xmlns/graphml http://www.yworks.com/xml/schema/graphml/1.0/ygraphml.xsd');
docRootNode.setAttribute('xmlns:y','http://www.yworks.com/xml/graphml');



%% Define node Attributes:
NodeAttribute = GraphDocument.createElement('key');
NodeAttribute.setAttribute('id','d0');
NodeAttribute.setAttribute('for','node');
NodeAttribute.setAttribute('yfiles.type','nodegraphics');
docRootNode.appendChild(NodeAttribute);

NodeAttribute = GraphDocument.createElement('key');
NodeAttribute.setAttribute('id','d1');
NodeAttribute.setAttribute('for','node');
NodeAttribute.setAttribute('yfiles.type','edgegraphics');
docRootNode.appendChild(NodeAttribute);

NodeAttribute = GraphDocument.createElement('key');
NodeAttribute.setAttribute('id','d3');
NodeAttribute.setAttribute('for','edge');
NodeAttribute.setAttribute('attr.name','IntValue');
NodeAttribute.setAttribute('attr.type','int');
docRootNode.appendChild(NodeAttribute);

NodeAttribute = GraphDocument.createElement('key');
NodeAttribute.setAttribute('id','d4');
NodeAttribute.setAttribute('for','graph');
NodeAttribute.setAttribute('attr.name','StringValue');
NodeAttribute.setAttribute('attr.type','string');
docRootNode.appendChild(NodeAttribute);

NodeAttribute = GraphDocument.createElement('key');
NodeAttribute.setAttribute('id','d2');
NodeAttribute.setAttribute('for','edge');
NodeAttribute.setAttribute('yfiles.type','edgegraphics');
docRootNode.appendChild(NodeAttribute);

%% CREATE GRAPH
GraphMLNode = GraphDocument.createElement('graph');
GraphMLNode.setAttribute('id',['G_' Graph.FileName]);
if Directionality
    GraphMLNode.setAttribute('edgedefault','directed');
else
    GraphMLNode.setAttribute('edgedefault','undirected');
end
GraphMLNode.setAttribute('parse.maxindegree',num2str(max(Degrees(:,2))));
GraphMLNode.setAttribute('parse.maxoutdegree',num2str(max(Degrees(:,3))));
GraphMLNode.setAttribute('parse.nodeids','canonical');
GraphMLNode.setAttribute('parse.edgeids','canonical');
GraphMLNode.setAttribute('parse.order','nodesfirst');

docRootNode.appendChild(GraphMLNode);

%% Write node names:

for i = 1 : numel(NodeIDs)
    Node = GraphDocument.createElement('node');

    Node.setAttribute('id',num2str(NodeIDs(i)));
    Node.setAttribute('parse.indegree',num2str(Degrees(i,2)));
    Node.setAttribute('parse.outdegree',num2str(Degrees(i,3)));
    GraphMLNode.appendChild(Node);

    NodeData = GraphDocument.createElement('data');
    NodeData.setAttribute('key','d0');
    ShapeNode = GraphDocument.createElement('y:ShapeNode');
    Shape = GraphDocument.createElement('y:Shape');
    Shape.setAttribute('type',NodeShapesList{NodeShapes(i)});
    NodeData.appendChild(ShapeNode);    
    NodeLabel = GraphDocument.createElement('y:NodeLabel');
    %NodeLabel = GraphDocument.createTextNode('y:NodeLabel');
    NodeLabel.setAttribute('visible','true');
    NodeLabel.setAttribute('modelName','internal');
    NodeLabel.setAttribute('modelPosition','c');
    NodeLabel.setAttribute('autoSizePolicy','content');
    NodeName = GraphGetNodeNames(Graph,NodeIDs(i));
    if isempty(NodeName)
        NodeName = num2str(NodeIDs(i));
    end
    if iscell(NodeName) 
        NodeName = NodeName{1};
    end
    
%    NodeName = num2str(AllNodeIDs(i));
%    NodeLabel.appendChild( GraphDocument.createTextNode(NodeName));
%    NodeLabel.appendChild( GraphDocument.createTextNode(num2str(AllNodeIDs(i))));
%    set(NodeLabel,'TextContent',NodeName);
    NodeLabel.setTextContent(NodeName);
    ShapeNode.appendChild(NodeLabel);
    ShapeNode.appendChild(Shape);
    Color = ['#' sprintf('%2x',Colormap(NodeColors(i),:))];
    Color(Color==' ')='0';    
    
    NodeFill = GraphDocument.createElement('y:Fill');
    NodeFill.setAttribute('color',Color);
    NodeFill.setAttribute('transparent','false');
    ShapeNode.appendChild(NodeFill);
    
    Node.appendChild(NodeData);
end
      

%% write edges
for i = 1 : size(Graph.Data,1)
    Edge = GraphDocument.createElement('edge');
    Edge.setAttribute('target',num2str(Graph.Data(i,2)));
    Edge.setAttribute('source',num2str(Graph.Data(i,1)));
    Edge.setAttribute('id',['Edge_' num2str(i)]);
    EdgeData  = GraphDocument.createElement('data');
    EdgeData.setAttribute('key','d1');
    PolyLineEdge = GraphDocument.createElement('y:PolyLineEdge');
    Path = GraphDocument.createElement('y:Path');
    Path.setAttribute('sx','0.0');
    Path.setAttribute('sy','0.0');
    Path.setAttribute('tx','0.0');
    Path.setAttribute('tx','0.0');
    LineStyle = GraphDocument.createElement('y:LineStyle');
    LineStyle.setAttribute('type','line');
    % LineStyle.setAttribute('width','1.0');
    LineStyle.setAttribute('width',num2str(Graph.Data(i,3)));
    LineColor= ['#' sprintf('%2x',Colormap(EdgeColor(i),:))];
    LineColor(LineColor==' ')='0';    
    LineStyle.setAttribute('color',LineColor);
    Arrows = GraphDocument.createElement('y:Arrows');
    Arrows.setAttribute('source','standard');
    Arrows.setAttribute('target','standard');
    BendStyle= GraphDocument.createElement('y:BendStyle');
    BendStyle.setAttribute('smoothed','false');          
    
    PolyLineEdge.appendChild(Path);
    PolyLineEdge.appendChild(LineStyle);
    PolyLineEdge.appendChild(Arrows);    
    PolyLineEdge.appendChild(BendStyle);
    EdgeData.appendChild(PolyLineEdge);
    Edge.appendChild(EdgeData);
    GraphMLNode.appendChild(Edge);
end

%{ 
GraphDocument
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns 
        http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
docRootNode = GraphDocument.getDocumentElement;
%}
xmlwrite(FileName,GraphDocument);

%% Helper methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput
%% 
DefaultInput = {};
DefaultInput    =   FIOAddParameter(DefaultInput,'Directionality',1);
h1 = figure('Visible','off');
Colormap = colormap;
close(h1);
Colormap = round(Colormap*255);
DefaultInput    =   FIOAddParameter(DefaultInput,'Colormap',Colormap);
DefaultInput    =   FIOAddParameter(DefaultInput,'NodeIDs',[]);
DefaultInput    =   FIOAddParameter(DefaultInput,'NodeColors',[]);
DefaultInput    =   FIOAddParameter(DefaultInput,'EdgeColor',[]);
NodeShapesList  =   {'hexagon','diamond','parallelogram','octagon','ellipse','trapezoid','rectangle3d','roundrectangle','trapezoid2','Triangle','rectangle'};
DefaultInput    =   FIOAddParameter(DefaultInput,'NodeShapesList',NodeShapesList);
DefaultInput    =   FIOAddParameter(DefaultInput,'NodeShapes',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

