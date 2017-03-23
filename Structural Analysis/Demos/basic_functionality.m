%BASICFUNCTIONALITY- Demo script of the basic functionality in fault-diagnosis 
%
% Author: George Zogopoulos-Papaliakos
% Control Systems Laboratories, School of Mechanical Engineering, National
% Technical University of Athens
% email: gzogop@mail.ntua.gr
% Website: https://github.com/Georacer
% March 2017; Last revision: 23/03/2017

clear
clc

%% Create a new graph and examine it

% Load a structural system model
model = g007();

% Create a new GraphInterface object
initialGraph = GraphInterface();
% Read the model
initialGraph.readModel(model);
% Build the adjacency matrices
initialGraph.createAdjacency();

% The initial graph has a GraphBipartite, a Registry and an Adjacency
% member
disp(initialGraph);

% The graph member contains all of the graph element arrays
disp(initialGraph.graph);

% The adjacency member contains the bidirectional, the equation-to-veriable
% and variable-to-equation adjacency matrices
disp(initialGraph.adjacency);

% Create a new plotter object
plotter = Plotter(initialGraph);
% Create a dot graph and compile it
plotter.plotDot('initial');
% The output .ps image is in the g008 folder
% Open the image. Note how every equation is a rectrangle and every
% variable is a circle. All graph elements display their ID below them.

%% Graph element discovery

% Get the IDs of all the variables in the graph
variableIdArray = initialGraph.getVariables()

% Get the names of all the variables
variableNames = initialGraph.getAliasById(variableIdArray)

% Get the equations which use the first variable
equ1 = initialGraph.getEquations(variableIdArray(1))

% Get the edge between the first variable and the first equation
edge1 = initialGraph.getEdgeIdByVertices(equ1(1),variableIdArray(1))

%% Discover element by property

% Find all of the known variables
knownVars = initialGraph.getVariablesKnown;
initialGraph.getAliasById(knownVars)

% Find all of the inputs
inputVars = initialGraph.getVarIdByProperty('isInput');
initialGraph.getAliasById(inputVars)
