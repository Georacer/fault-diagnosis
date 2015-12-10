function [ ] = printTable( Graph )
%PRINTTABLE Make csv file representation of a Graph

% T = array2table(Graph.adjacency); // Available only form r2013b and
% beyond

% This fails in my Ubuntu
% dataCell = num2cell(Graph.adjacency);
% finalCell = [{''} Graph.vars ; Graph.constraints' dataCell];
% xlswrite('adjacency.xls',finalCell);

%% Create the CSV file

dataCell = num2cell(char(Graph.adjacency));
finalCell = [{''} Graph.vars ; Graph.constraints' dataCell];
[nrows,ncols] = size(finalCell);
fileID = fopen('adjacency.csv','w');

% Write the first row
formatSpec = '';
for i=1:ncols
    formatSpec = [formatSpec '%s'];
   if i < ncols
       formatSpec = [formatSpec '\t'];
   else
       formatSpec = [formatSpec '\n'];
   end
end
fprintf(fileID, formatSpec, finalCell{1,:});

% Write the rest of the rows
formatSpec = '%s\t';
for i=2:ncols
    formatSpec = [formatSpec '%s'];
   if i < ncols
       formatSpec = [formatSpec '\t'];
   else
       formatSpec = [formatSpec '\n'];
   end
end
tempCell = finalCell.';
fprintf(fileID, formatSpec, tempCell{:,2:end});

fclose(fileID);

%% Create companion txt file with the equation IDs

fileID = fopen('constraintIDs.txt','w');
for i=1:length(Graph.constraints)
    fprintf(fileID,'%s: ',Graph.constraints{i});
    varnames = Graph.vars(1,Graph.adjacency(find(strcmp(Graph.constraints,Graph.constraints{i})),:)~=0);
    fprintf(fileID,'%s, ',varnames{:});
    fprintf(fileID,'\n');
end
fclose(fileID);


end