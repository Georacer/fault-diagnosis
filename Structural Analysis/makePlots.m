%% Parse stored data and create plots

%% Benchmark comparisons between BBILP methodologies

clear
clc
close all

x1 = [1 4 7] + 0.5;
x2 = x1+1;

cheapest_MTES = 'BBILP_cheap_MTES';
dfs_MTES = 'BBILP_cheap_MTES';
bfs_MTES = 'BBILP_cheap_MTES';
cheapest_MSO = 'BBILP_cheap_MTES';
dfs_MSO = 'BBILP_cheap_MTES';
bfs_MSO = 'BBILP_cheap_MTES';

files_MTES = {cheapest_MTES, dfs_MTES, bfs_MTES};
files_MSO = {cheapest_MSO, dfs_MSO, bfs_MSO};

load(cheapest_MTES);
numExperiments = length(stats);
experimentNames = {stats.name};
clear stats
barWidth = 1/diff(x1(1:2));

data_MTES = zeros(3,numExperiments);
data_MSO = data_MTES;

% Load MTES data
for i=1:length(files_MTES)
    load(files_MTES{i});
    timeSetGen = cell2mat({stats.timeSetGen});
    timeMakeSG = cell2mat({stats.timeMakeSG});
    timeSolveILP = cell2mat({stats.timeSolveILP});
    data_MTES(i,:) = timeSetGen + timeSolveILP;
    clear stats
end

% Load MSO data
for i=1:length(files_MSO)
    load(files_MTES{i});
    timeSetGen = cell2mat({stats.timeSetGen});
    timeMakeSG = cell2mat({stats.timeMakeSG});
    timeSolveILP = cell2mat({stats.timeSolveILP});
    data_MSO(i,:) = timeSetGen + timeSolveILP;
    clear stats
end

fh = figure();

h1 = barh(x1,data_MTES,'stacked','BarWidth',barWidth); % this should make a stacked bar graph located at the x1 coordinates
set(gca,'nextplot','add') %add on to the current graph
h2 = barh(x2,data_MSO,'stacked','BarWidth',barWidth); %this adds another set of bar graphs on the same plot next to it to make two %series with stacked bar graphs

% Set axis properties
ah = fh.Children;
ah.YLim = [0 10];
ah.YTick = 0:10;
ah.YTickLabel = {'','','Cheapest','','','BFS','','','DFS',''};
ah.YLabel.String = 'Branching Method';
ah.XLabel.String = 'Cumulative Solution Time';

