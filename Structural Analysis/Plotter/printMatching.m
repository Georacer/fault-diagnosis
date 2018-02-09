function [ ] = printMatching( digraph, solutionOrder, fileName, format, useAlias)
%PRINTMATCHING Print the calculation sequence of a directed graph
%   In a friendly way that will allow later the extraction of the
%   analytical calculation sequence
%
%   OUTPUT: Equation IDs, in the order they should be evaluated. Each line
%   is an SCC


debug = true;

%% Create a CSV file with residual signatures

if nargin<2
    return
end

if nargin<4
    format = 'single';
end

if nargin<5
    useAlias = false;
end

if isempty(fileName)
    if useAlias
        alias = digraph.getAliasById(RGids);
        fileName = sprintf('calc_sequence_%s.csv', alias{:});
    else
        fileName = sprintf('calc_sequence_%d.csv', RGids);
    end
end

fileID = fopen(fileName,'w');

% Write the first row
formatSpec = 'Calculation sequence for equation %d\n';
fprintf(fileID, formatSpec, solutionOrder{end});

% Write the rest of the rows

%% Single-line format
if strcmp(format,'single')
    
    for i=1:(length(solutionOrder)-1)
        SCC = solutionOrder{i};
        numEqs = length(SCC);
        formatSpec = [];
        for i=1:numEqs
            if useAlias
                formatSpec = [formatSpec '%s->%s'];
            else
                formatSpec = [formatSpec '%d->%d'];
            end
            if i<numEqs
                formatSpec = [formatSpec ',\t'];
            else
                formatSpec = [formatSpec '\n'];
            end
        end
        matchedVars = digraph.getMatchedVars(SCC);
        if useAlias
            data = [digraph.getAliasById(SCC);...
                digraph.getAliasById(matchedVars)];
            data = reshape(data, 1, 2*length(SCC));
            fprintf(fileID, formatSpec, data{:});
        else
            data = [SCC; matchedVars];
            data = reshape(data, 1, 2*length(SCC));
            fprintf(fileID, formatSpec, data);
        end
    end
    
%% Multi-line format
elseif strcmp(format,'multi')
    
    for i=1:(length(solutionOrder)-1)
        SCC = solutionOrder{i};
        numEqs = length(SCC); 
        formatSpec = '$\n';   
        for i=1:numEqs
            if useAlias
                formatSpec = [formatSpec '%s,%s\n'];
            else
                formatSpec = [formatSpec '%d,%d\n'];
            end
        end
        matchedVars = digraph.getMatchedVars(SCC);
        if useAlias
            data = [digraph.getAliasById(SCC);...
                digraph.getAliasById(matchedVars)];
            data = reshape(data, 1, 2*length(SCC));
            fprintf(fileID, formatSpec, data{:});
        else
            data = [SCC; matchedVars];
            data = reshape(data, 1, 2*length(SCC));
            fprintf(fileID, formatSpec, data);
        end    
    end
    
else
    error('unknown format type %s',format);
end

%% Write the residual

fprintf(fileID, '$\n');
if useAlias
    alias = digraph.getAliasById(RGids);
    fprintf(fileID, '%s', alias{:});
else
    fprintf(fileID, '%d', solutionOrder{end});
end

fclose(fileID);

end

