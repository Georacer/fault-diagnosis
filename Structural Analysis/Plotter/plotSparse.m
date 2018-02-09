function plotSparse( gh )
%PLOTSPARSE Summary of this function goes here
%   Detailed explanation goes here

subplot(2,2,[1,3])
spy(gh.adjacency.BD);
set(gca,'XTick',0:(gh.numVars+gh.numEqs+1));
set(gca,'YTick',0:(gh.numVars+gh.numEqs+1));
set(gca,'XTickLabel',[{''} gh.variableAliasArray gh.equationAliasArray {''}]);
set(gca,'YTickLabel',[{''} gh.variableAliasArray gh.equationAliasArray {''}]);
xticklabel_rotate([],90,[]);

subplot(2,2,2)
spy(gh.adjacency.E2V);
set(gca,'YTick',0:(gh.numEqs+1));
set(gca,'XTick',0:(gh.numVars+1));
set(gca,'YTickLabel',[{''} gh.equationAliasArray {''}]);
set(gca,'XTickLabel',[{''} gh.variableAliasArray {''}]);
xticklabel_rotate([],90,[]);

subplot(2,2,4)
spy(gh.adjacency.V2E);
set(gca,'YTick',0:(gh.numVars+1));
set(gca,'XTick',0:(gh.numEqs+1));
set(gca,'YTickLabel',[{''} gh.variableAliasArray {''}]);
set(gca,'XTickLabel',[{''} gh.equationAliasArray {''}]);
xticklabel_rotate([],90,[]);

end

