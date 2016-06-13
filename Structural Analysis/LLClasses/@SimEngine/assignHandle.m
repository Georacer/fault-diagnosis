% Assign the function handle in the fh cell array
function assignHandle(this, fileID, equId, varId)
equIndex = this.gh.getIndexById(equId);
varIds = this.gh.getVariables(equId);
varIndex = find(varIds==varId);
funName = sprintf('f_%d_%d',equId,varId);
s = sprintf('fArray{%d}{%d} = @%s;\n',equIndex, varIndex, funName);
fprintf(fileID,s);
end