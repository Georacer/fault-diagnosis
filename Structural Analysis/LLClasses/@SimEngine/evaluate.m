% Evaluate the requested function
function val = evaluate(this, equId, varId, args)
equIndex = this.gh.getIndexById(equId);
varIds = this.gh.getVariables(equId);
varIndex = find(varIds==varId);
val = feval(this.functionArray{equIndex}{varIndex},args{:});
end