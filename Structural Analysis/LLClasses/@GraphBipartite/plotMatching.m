function plotMatching( obj )
%PLOTMATCHING Generate dot code for plotting the matched graph
%   Detailed explanation goes here

fileID = fopen('mygraphmatched.dot','w');
% Write header
fprintf(fileID,'digraph G {\n');
fprintf(fileID,'rankdir = LR;\n');
fprintf(fileID,'size ="8.5"\n');
nodeDef = '';
edgeDef = '';
rankDef = '';
for i=1:obj.numEqs
    color = 'white';
    if obj.equationArray(i).isMatched
        color = 'cyan';
    end
    if obj.equationArray(i).isResGenerator
        nodeDef = [nodeDef sprintf('node [shape = circle, fillcolor = cyan, style = filled, label = "RES-%d"]; res_%d;\n'...
            ,obj.equationIdArray(i),obj.equationIdArray(i))];
        edgeDef = [edgeDef sprintf('%s -> res_%d [penwidth = 1.5];\n',obj.equationAliasArray{i},obj.equationIdArray(i))];
    end
    nodeDef = [nodeDef sprintf('node [shape = box, fillcolor = %s, style = filled, label="%s\n%d"]; %s;\n'...
        ,color,obj.equationAliasArray{i},obj.equationIdArray(i),obj.equationAliasArray{i})];
    for j=1:obj.equationArray(i).numVars
        flagE2V = false;
        flagV2E = true;
        shape = 'circle';
        penwidth = 1;
        color = 'white';
        if obj.equationArray(i).variableArray(j).isKnown
            color = 'cyan';
        end
        if obj.equationArray(i).variableArray(j).isMeasured
            flagE2V = false;
            color = 'yellow';
        end
        if obj.equationArray(i).variableArray(j).isInput
            color = 'green';
            shape = 'doublecircle';
        end
        if obj.equationArray(i).variableArray(j).isOutput
            shape = 'Mcircle';
        end
        if obj.equationArray(i).variableArray(j).isMatched
            penwidth = 1.5;
            flagV2E = false; % From variable to equation
            flagE2V = true; % From equation to variable
        end
        if obj.equationArray(i).variableArray(j).isDerivative
            % No operation, unless causality says otherwise
        end
        if obj.equationArray(i).variableArray(j).isIntegral
            % No operation, unless causality says otherwise
        end
        if obj.equationArray(i).variableArray(j).isNonSolvable
            flagE2V = false; % From equation to variable
        end
        % Specify variable node
        %                     nodeDef = [nodeDef sprintf('%s [shape = %s, fillcolor = %s];\n',obj.equationArray(i).variableAliasArray{j},shape,color)];
        nodeDef = [nodeDef sprintf('node [shape = %s, fillcolor = %s, style = filled, label="%s\n%d"]; %s;\n'...
            ,shape,color,obj.equationArray(i).variableAliasArray{j},obj.equationArray(i).variableIdArray(j),obj.equationArray(i).variableAliasArray{j})];
        % Equation to Variable
        if flagE2V
            edgeDef = [edgeDef sprintf('%s -> %s [penwidth = %g];\n',obj.equationArray(i).prAlias,obj.equationArray(i).variableAliasArray{j},penwidth)];
        end
        % Variable to Equation
        if flagV2E
            edgeDef = [edgeDef sprintf('%s -> %s [penwidth = %g];\n',obj.equationArray(i).variableAliasArray{j},obj.equationArray(i).prAlias,penwidth)];
        end
    end
end

% Generate rank groups
% Calculate maximum achieved rank
maxRank = 0;
for i=1:obj.numEqs
    if obj.equationArray(i).rank > maxRank && obj.equationArray(i).rank ~= inf
        maxRank = obj.equationArray(i).rank;
    end
end
varVector = cell(2*(maxRank+1),1);
for i=1:obj.numEqs
    rank = obj.equationArray(i).rank;
    varVector{2*rank,end+1} = obj.equationArray(i).prAlias;
    if obj.equationArray(i).isResGenerator
        varVector{2*rank+1,end+1} = sprintf('res_%d',obj.equationArray(i).id);
    end
end
for i=1:obj.numVars
    rank = obj.variableArray(i).rank;
    varVector{2*rank+1,end+1} = obj.variableArray(i).alias;
end

% Write the rank strings
for i=1:size(varVector,1)
    rankDef = [rankDef sprintf('{ rank=same;')];
    for j=1:size(varVector,2)
        alias = varVector{i,j};
        if ~isempty(alias)
            rankDef = [rankDef sprintf(' %s',alias)];
        end
    end
    rankDef = [rankDef sprintf('}\n')];
end
fprintf(fileID,nodeDef);
fprintf(fileID,edgeDef);
fprintf(fileID,rankDef);


% Close file
fprintf(fileID,'}\n');
fclose(fileID);

% Run 'dot -Tps mygraphmatched.dot -o mygraphmatched.ps' in the command line
s = system('dot -Tps mygraphmatched.dot -o mygraphmatched.ps');
if s
    warning('Failed to run "dot" command to generate graph image');
end

end

