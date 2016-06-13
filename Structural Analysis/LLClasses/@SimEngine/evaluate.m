% Evaluate the requested function
function val = evaluate(this, equId, varId, args)

% debug = true;
debug = false;

equIndex = this.gh.getIndexById(equId);
varIds = this.gh.getVariables(equId);
varIndex = find(varIds==varId);

if debug warning(sprintf('Calling function functionArray{%d}{%d}\n',equIndex,varIndex)); end

val = feval(this.functionArray{equIndex}{varIndex},args{:});
end