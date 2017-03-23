function [  ] = printMatching( Graph, matching )
%PRINTMATCHING Summary of this function goes here
%   Detailed explanation goes here

%% Create companion txt file with variable ranks
fileID = fopen('rankVars.txt','w');
for i=1:length(matching.rankVar)
    fprintf(fileID,'%s\t:\t%d\n',Graph.vars{i},matching.rankVar(i));
end
fclose(fileID);

%% Create companion txt file with constraint ranks
fileID = fopen('rankCons.txt','w');
for i=1:length(matching.rankCon)
    fprintf(fileID,'%s\t:\t%d\n',Graph.constraints{i},matching.rankCon(i));
end
fclose(fileID);

%% Create companion txt file with matching edges
fileID = fopen('matching.txt','w');
for i=1:size(matching.edges,1)
    fprintf(fileID,'%s\t<-\t%s\n',Graph.vars{matching.edges(i,1)},Graph.constraints{matching.edges(i,2)});
end
fclose(fileID);

%% Create a CSV file with residual signatures

if size(matching.signatures,2)~=0
    numCons = length(Graph.constraints);
    output = cell((1+sum(matching.residuals)),numCons+1);
    output(1,:) = [{''}, Graph.constraints];
    output(2:end,1) = Graph.constraints(find(matching.residuals))';
    output(2:end,2:end) = num2cell(matching.signatures);

    [nrows,ncols] = size(output);
    fileID = fopen('signatures.csv','w');

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
    fprintf(fileID, formatSpec, output{1,:});

    % Write the rest of the rows
    formatSpec = '%s\t';
    for i=2:ncols
        formatSpec = [formatSpec '%d'];
       if i < ncols
           formatSpec = [formatSpec '\t'];
       else
           formatSpec = [formatSpec '\n'];
       end
    end
    tempCell = output.';
    fprintf(fileID, formatSpec, tempCell{:,2:end});

    fclose(fileID);
else
    disp('Cannot write signatures.csv - No signatures available');
end

end

