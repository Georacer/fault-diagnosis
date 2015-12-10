function [ Graph ] = modelParser( modelfile )
%MODELPARSER Create a directed adjacency matrix
%   Parse a modelFile cell array containing a set of model equations and
%   create a directed adjacency matrix

adjacency = []; % Create the overall adjacency matrix
conNames = cell(0,0);
UVars = cell(0,0);
KVars = cell(0,0);

% Parse each equation group separately
groupsNum = size(modelfile,1);
for groupIndex=1:groupsNum
    group = modelfile{groupIndex,1};
    grEqNum = size(group,1);
    grPrefix = modelfile{groupIndex,2};
    grEqNames = cell(1,grEqNum);
    % Construct the equation IDs
    for i=1:grEqNum
        grEqNames{i} = strcat(grPrefix,num2str(i,'%i'));
    end
    conNames = [conNames grEqNames];
    for i=1:grEqNum
        [adjacency,UVars,KVars] = lineParser(group{i,1},adjacency,UVars,KVars);
    end
end

Graph.vars = [UVars KVars];
numVars = length(Graph.vars);
Graph.constraints = conNames;
numCons = length(Graph.constraints);

% Graph.adjacency = [zeros(size(adjacency,2)) adjacency';...
%                     adjacency zeros(size(adjacency,1))];
% Filter out directional elements
% Directionalize for msr variables
% Graph.adjacency(:,1:length(KVars))=0;
% Directionalize for non-invertible variables
% Graph.adjacency(Graph.adjacency(:,1:numVars)=='X')=0;
% Directionalize for trigonometric variables
% Graph.adjacency(Graph.adjacency(1:numVars,:)=='T')=0;

Graph.adjacency = adjacency;
Graph.isInput = [zeros(1,length(UVars)) ones(1,length(KVars))];
Graph.isMatched = zeros(1,size(Graph.adjacency,1));

Graph.coords = [];

end

