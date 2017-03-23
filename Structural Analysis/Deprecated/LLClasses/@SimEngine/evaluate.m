% Evaluate the requested function
function val = evaluate(this, equId, varId, args)

debug = true;
% debug = false;

equIndex = this.gh.getIndexById(equId);
varIds = this.gh.getVariables(equId);
varIndex = find(varIds==varId);

if debug fprintf('evaluate: Calling function functionArray{%d}{%d}\n',equIndex,varIndex); end
if debug fprintf('evaluate: With %d arguments\n',length(args)); end
    
val = this.functionArray{equIndex}{varIndex}.evaluate(args);
end