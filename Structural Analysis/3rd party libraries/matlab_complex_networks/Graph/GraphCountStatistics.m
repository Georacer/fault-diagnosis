function [varargout] = GraphCountStatistics(Graph)
% The function geathers and prints all available statistics about the graph.
%
% Receives:
%   Graph       -   Graph Struct                                -   the graph loaded with GraphLoad
%                      -    string                                            -    Name of file containing the graph
%
% Returns:
%   Statistics  -   struct                                      -   struct containing statistics. If no placeholder for the output is given, the data is printed in workspace.
%
% See Also:
%       GraphLoad, GraphPlotNodesDegreeDistribution,...
%
%   Example:
%   GraphCountStatistics('E:\Documents\Articles\Data\ColiNet\CoilInterNoAutoRegVec.Graph');
% 


error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

if ischar(Graph)
    Graph = GraphLoad(Graph);
end
Statistics =[];
Statistics.NumberOfNodes = GraphCountNumberOfNodes(Graph);
Statistics.NumberOfLinks = GraphCountNumberOfLinks(Graph);
Degree = GraphCountNodesDegree(Graph);
Statistics.InZeroDegreeCount = nnz(Degree(:,2)==0);
Statistics.OutZeroDegreeCount = nnz(Degree(:,3)==0);

GraphPlotNodesDegreeDistributionNature(Graph,'NumberOfInBins',12,'DataType','both','InFitRange',[0.2 1.7]);
if ~nargout
    disp(['File Name: '  Graph.FileName]);
    disp(['Number of Nodes: '  num2str(Statistics.NumberOfNodes)]);
    disp(['Number of Links: '  num2str(Statistics.NumberOfLinks)]);
    disp(['Average Number of Links: '  num2str(Statistics.NumberOfLinks/Statistics.NumberOfNodes)]);    
    disp(['In 0-degree count: '  num2str(Statistics.InZeroDegreeCount )]);    
    disp(['Out 0-degree count: '  num2str(Statistics.OutZeroDegreeCount )]);    

    
else
    varargout{1} =Statistics;
end

