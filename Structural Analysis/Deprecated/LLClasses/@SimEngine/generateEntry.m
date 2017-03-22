% Generate a new function entry for one function evaluation
function generateEntry(eh, fileID, equId, varId)

% debug = true;
debug = false;

% Write first row
varAlias = eh.gh.getAliasById(varId);
edgeId = eh.gh.getEdgeIdByVertices(equId, varId);
if debug fprintf('generateEntry: Examining edge with ID %d\n',edgeId); end

if (eh.gh.getPropertyById(edgeId,'isIntegral') || eh.gh.getPropertyById(edgeId,'isDerivative')) % This is an integrator or differentiator
    return
end

s = sprintf('\nfunction %s = f_%d_%d(',varAlias{:},equId,varId);
equIndex = eh.gh.getIndexById(equId);
equAlias = eh.gh.getAliasById(equId);
varIds = eh.gh.getVariables(equId);
numVars = length(varIds);
otherVars = setdiff(varIds,varId);
varNames = eh.gh.getAliasById(otherVars);

if length(varNames)>1
    s = [s sprintf('%s,',varNames{1:end-1})];
end
s = [s sprintf('%s', varNames{end})];
s = [s sprintf(')\n')];
fprintf(fileID,s);

% Write comments
%             s = [s sprintf('%% Evaluation definition for equation %s with id %d\n',equAlias{:}, equId)];
fprintf(fileID,'%% Evaluation definition for equation %s with id %d\n',equAlias{:}, equId);
fprintf(fileID,'%% Equation structural description: %s\n',eh.gh.equations(equIndex).expressionStructural);
fprintf(fileID,'%% Evaluate for variable: %s\n\n', varAlias{:});

s = '';
if eh.gh.isMatchable(edgeId)
    % Write placeholder text
    if debug fprintf('generateEntry: This edge is matchable\n'); end
    fprintf(fileID,'%% Write calculation here\n');
else
    % Write error message
    if debug fprintf('generateEntry: This edge is not matchable\n'); end
    fprintf(fileID,'error(''This evaluation is not possible'');\n');
end

% Close the function
fprintf(fileID,'end\n');
end

