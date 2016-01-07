function plotMatching( gh )
%PLOTMATCHING Generate dot code for plotting the matched graph
%   Detailed explanation goes here

fileID = fopen('mygraphmatched.dot','w');
% Write header
fprintf(fileID,'digraph G {\n');
fprintf(fileID,'rankdir = LR;\n');
fprintf(fileID,'size ="8.5"\n');
equDef = 'node [shape = box, fillcolor = cyan, style = filled]; ';
varDef = 'node [shape = circle, fillcolor = cyan, style = filled]; ';
msrDef = 'node [shape = circle, fillcolor = yellow, style = filled]; ';
inpDef = 'node [shape = doublecircle, fillcolor = green, style = filled]; ';
outDef = 'node [shape = Mcircle, fillcolor = cyan, style = filled]; ';
resDef = 'node [shape = circle, fillcolor = orange, style = filled]; ';
edgeDef = '';
rankDef = '';

for i=1:gh.numEqs
    if gh.equations(i).rank ~= inf
        equDef = [equDef sprintf('%s; ',gh.equationAliasArray{i})];
    end
end

for i=1:gh.numVars
    if gh.variables(i).rank ~= inf
        if gh.variables(i).isMeasured
            msrDef = [msrDef sprintf('%s; ',gh.variableAliasArray{i})];
        elseif gh.variables(i).isInput
            inpDef = [inpDef sprintf('%s; ',gh.variableAliasArray{i})];
        elseif gh.variables(i).isOutput
            outDef = [outDef sprintf('%s; ',gh.variableAliasArray{i})];
        elseif gh.variables(i).isResidual
            resDef = [resDef sprintf('%s; ',gh.variableAliasArray{i})];
        else
            varDef = [varDef sprintf('%s; ',gh.variableAliasArray{i})];
        end
    end
end

for i=1:gh.numEdges
    penwidth = 1;
    equIndex = gh.getIndexById(gh.edges(i).equId);
    varIndex = gh.getIndexById(gh.edges(i).varId);
    if gh.isMatched(gh.edges(i).equId) || gh.isMatched(gh.edges(i).varId)
        if gh.isMatched(gh.edges(i).id)
            penwidth = 2;
            edgeDef = [edgeDef sprintf('%s -> %s [penwidth = %g];\n',gh.equations(equIndex).prAlias,gh.variableAliasArray{varIndex},penwidth)];
        else
            edgeDef = [edgeDef sprintf('%s -> %s [penwidth = %g];\n',gh.variableAliasArray{varIndex},gh.equations(equIndex).prAlias,penwidth)];
        end
    end
end


% Generate rank groups
% Calculate maximum achieved rank
maxRank = 0;
for i=1:gh.numEqs
    if gh.equations(i).rank > maxRank && gh.equations(i).rank ~= inf
        maxRank = gh.equations(i).rank;
    end
end
for i=1:gh.numVars
    if gh.variables(i).rank > maxRank && gh.variables(i).rank ~= inf
        maxRank = gh.variables(i).rank;
    end
end

varVector = cell(2*(maxRank+1),1);
for i=1:gh.numEqs
    rank = gh.equations(i).rank;
    if rank~=inf
        varVector{2*rank,end+1} = gh.equations(i).prAlias;
    end
end
for i=1:gh.numVars
    rank = gh.variables(i).rank;
    if rank~=inf
        varVector{2*rank+1,end+1} = gh.variables(i).alias;
    end
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

fprintf(fileID,[equDef '\n']);
fprintf(fileID,[varDef '\n']);
fprintf(fileID,[msrDef '\n']);
fprintf(fileID,[inpDef '\n']);
fprintf(fileID,[outDef '\n']);
fprintf(fileID,[resDef '\n']);
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

