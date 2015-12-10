function Graph = GraphSetNodeProperty(Graph,NodeIDs,Values,PropertyName,PropertyDescription)
% Sets node properties.
%
% Receives:
%       Graph      -   Graph Struct           -    the graph loaded with GraphLoad
%       NodeIDs    -   vector of integers     -    list of ids for which property values are provided.
%       Values     -   vector of any type     -    vector of property values.
%       PropertyName-  string                 -    String, whiche identifies the property.
%       PropertyDescription - string          -    Describes the 
%
% Returns:
%      NodeNames   -   cellstring             -    Names of the IDs in the order, identical to NodeIDs, If no IDs exist in the Graph, then empty cell is returen
% See Also:
%       GraphLoad, GraphGetNodeProperty
% 
% Example:
%   [WikiGraph Result]= WikiGraphLoad('DatabaseProperties.mat','hewiki');
%   Degree = GraphCountNodesDegree(WikiGraph);
%   WikiGraph  = GraphSetNodeProperty(WikiGraph ,Degree(:,1),Degree(:,2),'Inncoming Degree','Incoming node''s degree');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


error(nargchk(4,5,nargin));
error(nargoutchk(0,1,nargout));

ObjectIsType(Graph,'Graph','The input must be of the type "Graph". Please use ObjectCreateGraph function');

if ~exist('PropertyDescription','var')
    PropertyDescription = '';
end

Property = [];
Property.PropertyName = PropertyName;
Property.PropertyDescription = PropertyDescription;
Property.NodeIDs    =   NodeIDs;
Property.Values     =   Values;

if isempty(Graph.Index.Properties)
    Graph.Index.Properties = Property;
else
    Index = numel(Graph.Index.Properties)+1;
    for i = 1 : numel(Graph.Index.Properties)
        if strcmp(Graph.Index.Properties(i).PropertyName,PropertyName)
            Index = i;            
        end        
    end
    Graph.Index.Properties(Index) = Property;
end