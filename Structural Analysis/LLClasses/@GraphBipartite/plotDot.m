function plotDot(obj)
% Generate .dot code from this graph

fileID = fopen('mygraph.dot','w');
% Write header
fprintf(fileID,'digraph G {\n');
fprintf(fileID,'rankdir = LR;\n');
fprintf(fileID,'size ="8.5"\n');
nodeDef = '';
edgeDef = '';
for i=1:obj.numEqs
    nodeDef = [nodeDef sprintf('node [shape = box, fillcolor = white, style = filled, label="%s\n%d"]; %s;\n'...
        ,obj.equationAliasArray{i},obj.equationIdArray(i),obj.equationAliasArray{i})];
    for j=1:obj.equationArray(i).numVars
        flagE2V = true;
        flagV2E = true;
        shape = 'circle';
        penwidth = 1;
        color = 'white';
        if obj.equationArray(i).variableArray(j).isKnown
            % No operation
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

fprintf(fileID,nodeDef);
fprintf(fileID,edgeDef);

% Close file
fprintf(fileID,'}\n');
fclose(fileID);

% Run 'dot -Tps mygraph.dot -o mygraph.ps' in the command line
s = system('dot -Tps mygraph.dot -o mygraph.ps');
if s
    warning('Failed to run "dot" command to generate graph image');
end

end