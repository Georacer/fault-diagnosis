function plotDot(gh,graphName)
% Generate .dot code from this graph

debug = true;

if nargin<2
    graphName = 'myGraph';
end
dotName = sprintf('%s.dot',graphName);
imageName = sprintf('%s.ps',graphName);

fileID = fopen(dotName,'w');
% Write header
fprintf(fileID,'digraph G {\n');
fprintf(fileID,'rankdir = LR;\n');
fprintf(fileID,'size ="8.5"\n');
nodeDef = '';
edgeDef = '';

for i=1:gh.numEqs
    nodeDef = [nodeDef sprintf('node [shape = box, fillcolor = white, style = filled, label="%s\n%d"]; %s;\n'...
        ,gh.equationAliasArray{i},gh.equationIdArray(i),gh.equationAliasArray{i})];
end

for i=1:gh.numVars
    shape = 'circle';
    color = 'white';
    if gh.variables(i).isKnown
        % No operation
    end
    if gh.variables(i).isMeasured
        color = 'yellow';
    end
    if gh.variables(i).isInput
        color = 'green';
        shape = 'doublecircle';
    end
    if gh.variables(i).isOutput
        shape = 'Mcircle';
    end
    if gh.variables(i).isMatched
        % No operation
    end
    nodeDef = [nodeDef sprintf('node [shape = %s, fillcolor = %s, style = filled, label="%s\n%d"]; %s;\n'...
        ,shape,color,gh.variableAliasArray{i},gh.variableIdArray(i),gh.variableAliasArray{i})];
end

E = gh.getEdges();
for i=1:size(E,1)
    penwidth = 1;
    id1 = E(i,1);
    id2 = E(i,2);
    if gh.isVariable(id1) % V2E edge        
        varIndex = gh.getIndexById(id1);
        equIndex = gh.getIndexById(id2);
        edgeDef = [edgeDef sprintf('%s -> %s [penwidth = %g];\n',gh.variableAliasArray{varIndex},gh.equations(equIndex).prAlias,penwidth)];
    else% E2V edge
        equIndex = gh.getIndexById(id1);
        varIndex = gh.getIndexById(id2);
        if gh.isMatched(id2)
            penwidth = 1.5;
        end
        edgeDef = [edgeDef sprintf('%s -> %s [penwidth = %g];\n',gh.equations(equIndex).prAlias,gh.variableAliasArray{varIndex},penwidth)];
    end
end

fprintf(fileID,nodeDef);
fprintf(fileID,edgeDef);

% Close file
fprintf(fileID,'}\n');
fclose(fileID);

% Run 'dot -Tps mygraph.dot -o mygraph.ps' in the command line
s = system(sprintf('dot -Tps %s -o %s',dotName, imageName));
if s
    warning('Failed to run "dot" command to generate graph image');
end

end