%% Parse stored data and create plots 
 
%% Benchmark comparisons between BBILP methodologies 
% Excluding g005a and g014g models, because they do not finish in MSO mode
 
clear 
clc 
close all 
 
cheapest_MTES = 'BBILP_cheap_MTES'; 
dfs_MTES = 'BBILP_DFS_MTES'; 
bfs_MTES = 'BBILP_BFS_MTES'; 
cheapest_MSO = 'BBILP_cheap_MSO'; 
dfs_MSO = 'BBILP_DFS_MSO'; 
bfs_MSO = 'BBILP_BFS_MSO'; 
 
files_MTES = {cheapest_MTES, dfs_MTES, bfs_MTES}; 
files_MSO = {cheapest_MSO, dfs_MSO, bfs_MSO}; 
 
x1 = (1:3:(2*length(files_MTES)+1)) + 0.5; 
x2 = x1+1; 
 
load(cheapest_MTES); 
names = {'g008', 'g021','g022','g023','g024','g025','g026'}; 
numExperiments = length(names); 
clear stats 
barWidth = 1/diff(x1(1:2)); 

data_MTES = zeros(3,numExperiments); 
data_MSO = data_MTES; 
 
% Load MTES data 
timeSetGen = zeros(length(files_MTES),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(files_MTES) 
    load(files_MTES{i}); 
    for j=1:length(names)
        timeSetGen(i,j) = stats.(names{j}).timeSetGen; 
        timeMakeSG(i,j) = stats.(names{j}).timeMakeSG; 
        timeSolveILP(i,j) = stats.(names{j}).timeSolveILP; 
    end 
    clear stats 
end 
totalTime = timeSetGen + timeSolveILP; 
data_MTES = totalTime; 
 
% Load MSO data 
timeSetGen = zeros(length(files_MSO),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(files_MSO) 
    load(files_MSO{i}); 
    for j=1:length(names)
        timeSetGen(i,j) = stats.(names{j}).timeSetGen; 
        timeMakeSG(i,j) = stats.(names{j}).timeMakeSG; 
        timeSolveILP(i,j) = stats.(names{j}).timeSolveILP; 
    end 
    clear stats 
end 
totalTime = timeSetGen + timeSolveILP; 
data_MSO = totalTime; 
 
fh = figure(); 
 
h1 = barh(x1,data_MTES,'stacked','BarWidth',barWidth); % this should make a stacked bar graph located at the x1 coordinates 
set(gca,'nextplot','add') %add on to the current graph 
h2 = barh(x2,data_MSO,'stacked','BarWidth',barWidth); %this adds another set of bar graphs on the same plot next to it to make two %series with stacked bar graphs 
 
% Set axis properties 
ah = fh.Children; 
ah.YLim = [0 10]; 
ah.XLim = [ah.XLim(1) ah.XLim(2)+2]; 
ah.YTick = 0:10; 
ah.YTickLabel = {'','','Cheapest','','','BFS','','','DFS',''}; 
ah.YLabel.String = 'Branching Method'; 
ah.XLabel.String = 'Cumulative Solution Time (s)'; 
 
% Place explanatory text 
for i=1:length(x1) 
    x_coord = sum(data_MTES(i,:)); 
    text(x_coord+0.1,x1(i),'MTES'); 
end 
for i=1:length(x2) 
    x_coord = sum(data_MSO(i,:)); 
    text(x_coord+0.1,x2(i),'MSO'); 
end 
 
legend({names{:}}); 
set(ah,'xgrid','on') 
ah.GridColor = [0.2, 0.2, 0.2];  % [R, G, B] 
ah.GridAlpha = 0.9;
 
%% Benchmark comparisons between BBILP and exhaustive search 
% Excluding g005a and g014g models, because they do not finish in MSO mode
 
clear 
clc 
close all 
 
exhaustive_MSO = 'Exhaustive_DFS_MSO'; 
exhaustive_MTES = 'Exhaustive_DFS_MTES'; 
BBILP_MTES = 'BBILP_DFS_MTES'; 
BBILP_MSO = 'BBILP_DFS_MSO'; 
 
files_MTES = {BBILP_MTES, exhaustive_MTES}; 
files_MSO = {BBILP_MSO, exhaustive_MSO }; 
 
x1 = (1:3:(2*length(files_MTES)+1)) + 0.5; 
x2 = x1+1; 
 
load(BBILP_MTES); 
names = {'g008', 'g021','g022','g023','g024','g025','g026'}; 
numExperiments = length(names); 
clear stats 
barWidth = 1/diff(x1(1:2)); 
 
data_MTES = zeros(3,numExperiments); 
data_MSO = data_MTES; 
 
% Load MTES data 
timeSetGen = zeros(length(files_MTES),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(files_MTES) 
    load(files_MTES{i}); 
    for j=1:length(names); 
        timeSetGen(i,j) = stats.(names{j}).timeSetGen; 
        timeMakeSG(i,j) = stats.(names{j}).timeMakeSG; 
        timeSolveILP(i,j) = stats.(names{j}).timeSolveILP; 
    end 
    clear stats 
end 
totalTime = timeSetGen + timeSolveILP; 
data_MTES = totalTime; 
 
% Load MSO data 
timeSetGen = zeros(length(files_MSO),length(names)); 
timeMakeSG = timeSetGen; 
timeSolveILP = timeSetGen; 
for i=1:length(files_MSO) 
    load(files_MSO{i}); 
    for j=1:length(names)
        timeSetGen(i,j) = stats.(names{j}).timeSetGen; 
        timeMakeSG(i,j) = stats.(names{j}).timeMakeSG; 
        timeSolveILP(i,j) = stats.(names{j}).timeSolveILP; 
    end 
    clear stats 
end 
totalTime = timeSetGen + timeSolveILP; 
data_MSO = totalTime; 
 
fh = figure(); 
 
h1 = barh(x1,data_MTES,'stacked','BarWidth',barWidth); % this should make a stacked bar graph located at the x1 coordinates 
set(gca,'nextplot','add') %add on to the current graph 
h2 = barh(x2,data_MSO,'stacked','BarWidth',barWidth); %this adds another set of bar graphs on the same plot next to it to make two %series with stacked bar graphs 
 
% Set axis properties 
ah = fh.Children; 
ah.YLim = [0 7]; 
ah.XLim = [ah.XLim(1) ah.XLim(2)+2]; 
ah.YTick = 0:7; 
ah.YTickLabel = {'','','BBILP','','','Exhaustive','','',}; 
ah.YLabel.String = 'Matching Method'; 
ah.XLabel.String = 'Cumulative Solution Time (s)'; 
 
% Place explanatory text 
for i=1:length(x1) 
    x_coord = sum(data_MTES(i,:)); 
    text(x_coord+0.1,x1(i),'MTES'); 
end 
for i=1:length(x2) 
    x_coord = sum(data_MSO(i,:)); 
    text(x_coord+0.1,x2(i),'MSO'); 
end 
 
legend({names{:}},'Location','SE'); 
set(ah,'xgrid','on') 
ah.GridColor = [0.2, 0.2, 0.2];  % [R, G, B] 
ah.GridAlpha = 0.9;