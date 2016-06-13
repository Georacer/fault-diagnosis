% Generate a new function entry for one function evaluation
function generateEntry(this, fileID, equId, varId)
% Write first row
varAlias = this.gh.getAliasById(varId);
s = sprintf('\nfunction %s = f_%d_%d(',varAlias{:},equId,varId);
edgeId = this.gh.getEdgeIdByVertices(equId,varId);
equIndex = this.gh.getIndexById(equId);
equAlias = this.gh.getAliasById(equId);
varIds = this.gh.getVariables(equId);
numVars = length(varIds);
otherVars = setdiff(varIds,varId);
varNames = this.gh.getAliasById(otherVars);

if length(varNames)>1
    s = [s sprintf('%s,',varNames{1:end-1})];
end
s = [s sprintf('%s', varNames{end})];
s = [s sprintf(')\n')];
fprintf(fileID,s);

% Write comments
%             s = [s sprintf('%% Evaluation definition for equation %s with id %d\n',equAlias{:}, equId)];
fprintf(fileID,'%% Evaluation definition for equation %s with id %d\n',equAlias{:}, equId);
fprintf(fileID,'%% Equation structural description: %s\n',this.gh.equations(equIndex).expressionStructural);
fprintf(fileID,'%% Evaluate for variable: %s\n\n', varAlias{:});

s = '';
if this.gh.isMatchable(edgeId)
    % Write placeholder text
    fprintf(fileID,'%% Write calculation here\n');
else
    % Write error message
    fprintf(fileID,'error(''This evaluation is not possible'');\n');
end

% Close the function
fprintf(fileID,'end\n');
end

