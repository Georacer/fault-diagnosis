%% List which expressions have been used for the residual generation

fID = fopen('equationsExpr.csv','w');

equIds = unique(cell2mat(ResGenSets));
for i=1:length(equIds)
    index = graphInitial.getIndexById(equIds(i));
    alias = graphInitial.getAliasById(equIds(i));
    expression = graphInitial.graph.equations(index).expression;
    fprintf(fID,'%d,%s,%s,%s\n',equIds(i), alias{1}, graphInitial.getStrExprById(equIds(i)), expression);
end

fclose(fID);