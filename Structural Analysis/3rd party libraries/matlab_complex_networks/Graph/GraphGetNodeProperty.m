function Property = GraphGetNodeProperty(Graph,PropertyName,Nodes,Default)
% Returns the list of node Names, specified in the index of the graph
%
% Receives:
%       Graph      -   Graph Struct           -    the graph loaded with GraphLoad
%       PropertyName-  string                 -    String, whiche identifies the property.
%       Nodes      -   vector of integers     -    (optional) list of node ids for which property values are required. Default: [] (all nodes for which the properties are set). 
%       Default    -    scalar                -    (optional) If the property value is not specified for the node (in Nodes), this value will be provided for the property value. 
%                                                  Default: 0 for numeric properties, '' for textual
%
% Returns:
%      Property    -   structure              -    The structure with the required details. See GraphSetNodeProperty
%                                                  [] will be retured if no properties are found for the provided name.
% See Also:
%       GraphLoad, GraphsetNodeProperties
% 
% Example:
%   [WikiGraph Result]= WikiGraphLoad('DatabaseProperties.mat','hewiki');
%   Degree = GraphCountNodesDegree(WikiGraph);
%   WikiGraph  = GraphSetNodeProperty(WikiGraph ,Degree(:,1),Degree(:,2),'Incoming Degree','Incoming node''s degree');
%   Property = GraphGetNodeProperty(Graph,'Incoming Degree')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


error(nargchk(2,4,nargin));
error(nargoutchk(0,1,nargout));

ObjectIsType(Graph,'Graph','The input must be of the type "Graph". Please use ObjectCreateGraph function');

if ~exist('Nodes','var')
    Nodes = [];
end
Property = [];
try 
    Index = [];
    for i = 1 : numel(Graph.Index.Properties)
        if strcmp(Graph.Index.Properties(i).PropertyName,PropertyName)
            Index = i;
        end
    end
    if ~isempty(Index) % Get the property values!        
        if ~isempty(Nodes)
           Property.PropertyName        =   Graph.Index.Properties(Index).PropertyName;
           Property.PropertyDescription =   Graph.Index.Properties(Index).PropertyDescription;
           Property.NodeIDs = (Nodes);
           Property.Values = zeros(size(Property.NodeIDs));
           [c,ia,ib] = intersect(Property.NodeIDs,Graph.Index.Properties(Index).NodeIDs);
           Property.Values(ia) = Graph.Index.Properties(Index).Values(ib);
           [c i] = setdiff(Property.NodeIDs,Graph.Index.Properties(Index).NodeIDs);
           if ~isempty(i)
               if ~exist('Default','var') 
                   if ~isempty(Graph.Index.Properties(Index).Values)
                       if isnumeric(Graph.Index.Properties(Index).Values(1))
                           Default = 0;
                       else
                           Default = '';
                       end
                   else 
                       Default = 0;
                   end                   
               end
               Property.Values(i) = Default;
           end
        else
            Property = Graph.Index.Properties(Index);
        end
    end
catch
    Property = [];
end
