clear all;

input = {'deltat'};
output = {'T'};
knownVars = {'Vbs','Ns','deltat','Vas'};
unknownVars = {'Vs','qs','Vb','Is','Im','Vm','Ii','Ei','Pi','N','T','Va','np','J'};
vars = [knownVars unknownVars];
constraints = {'b1', 'b2', 'b3', 'e1', 'e2', 'm1', 'm2', 'm3', 'm4', 'p1', 'p2', 'p3', 's1', 's2', 's3'};

adjacency = zeros(size(constraints,2),size(vars,2));

edges = [1 5; 1 6;
    2 6; 2 8;
    3 5; 3 7; 3 8;
    4 3; 4 7; 4 10;
    5 8; 5 9;
    6 9; 6 10; 6 12;
    7 9; 7 10; 7 11;
    8 12; 8 14;
    9 11; 9 12; 9 13;
    10 14; 10 16; 10 18;
    11 17; 11 18;
    12 13; 12 15; 12 16; 12 17;
    13 1; 13 7;
    14 2; 14 14;
    15 16; 15 4];

for i=1:size(edges,1)
   adjacency(edges(i,1),edges(i,2))=1; 
end

Graph.adjacency = adjacency;
Graph.input = input;
Graph.output = output;
Graph.knownVars = knownVars;
Graph.unknownVars = unknownVars;
Graph.vars = vars;
Graph.constraints = constraints;