function specification( eh )
%SPECIFICATION Details on interface
%   Detailed explanation goes here

% Get the inputs and readings of the model
inpIds = eh.gh.getVarIdByProperty('isInput');
msrIds = eh.gh.getVarIdByProperty('isMeasured');
readingsIdArray = [inpIds msrIds];
evalIds = eh.evalIds;

inpAliasCell = eh.gh.getAliasById(inpIds);
msrAliasCell = eh.gh.getAliasById(msrIds);
readingsAliasCell = {inpAliasCell{:} msrAliasCell{:}};
evalAliasCell = eh.gh.getAliasById(evalIds);

fprintf('Input specification:\n');
fprintf('Number of readings: %d (%d inputs, %d measruements)\n',length(readingsIdArray), length(msrIds), length(msrIds));
fprintf('Inputs, in order:\n');
fprintf('%s,',inpAliasCell{:}); fprintf('\n');
fprintf('Measurements, in order:\n');
fprintf('%s,',msrAliasCell{:}); fprintf('\n');

fprintf('\nOutput specification:\n');
fprintf('Number of intermediate variables evaluations: %d\n',length(eh.evalIds));
fprintf('Intermediate variable aliases, in order:\n');
fprintf('%s,',evalAliasCell{:}); fprintf('\n');

end

