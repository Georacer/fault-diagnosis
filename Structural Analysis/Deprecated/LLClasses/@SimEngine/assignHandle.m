% Assign the function handle in the fh cell array
function assignHandle(eh, fileID, equId, varId)

funName = sprintf('f_%d_%d',equId,varId);
equIndex = eh.gh.getIndexById(equId);
varIds = eh.gh.getVariables(equId);
varIndex = find(varIds==varId);

edgeId = eh.gh.getEdgeIdByVertices(equId, varId);
if eh.gh.getPropertyById(edgeId,'isIntegral') % This is an integrator
    s = sprintf('fArray{%d}{%d} = Integrator();\n', equIndex, varIndex);
    fprintf(fileID,s);
elseif eh.gh.getPropertyById(edgeId,'isDerivative') % This is an integrator
    s = sprintf('fArray{%d}{%d} = Differentiator();\n', equIndex, varIndex);
    fprintf(fileID,s);
else
    s = sprintf('fArray{%d}{%d} = Function();\n',equIndex, varIndex);
    fprintf(fileID,s);
    s = sprintf('fArray{%d}{%d}.fh = @%s;\n',equIndex, varIndex, funName);
    fprintf(fileID,s);
end

end