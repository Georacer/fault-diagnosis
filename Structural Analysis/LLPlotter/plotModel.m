function [ figure_handles ] = plotModel( graph, plotType, plotName )
%MODELPLOT Plot a bipartite graph object
%   plot types - 0: .dot graphviz output
%                1: same as 0 plus compilation into .ps
%                2: Adjacency matrices
%                3: LiUSM PlotModel()
%                4: LiUSM PlotDM()

if nargin<2
    plotType = 0;
end

if nargin<3
    plotName = 'graph';
end

figure_handles = [];

% Create a .dot file
if (ismember(0,plotType) && ~ismember(1,plotType))
    graph.plotDot(plotName,false);
end

% Create a .dot file and a complied .ps image
if ismember(1,plotType)
    graph.plotDot(plotName,true);
end

% Display the adjacency matrices
if ismember(2,plotType)
    figure_handles(end+1) = figure();
    graph.plotSparse();
end

% Display the embedded LiUSM plotter
if ismember(3,plotType)
    figure_handles(end+1) = figure();
    graph.liusm.PlotModel();
    set(gca,'YTickLabel',mygraph.equationAliasArray);
end

% Display the LiUSM plotDM output
if ismember(4,plotType)
    figure_handles(end+1) = figure();
    graph.plotDM();
end

end

