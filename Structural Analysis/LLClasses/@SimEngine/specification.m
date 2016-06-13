function specification( eh )
%SPECIFICATION Details on interface
%   Detailed explanation goes here

% Get the inputs and readings of the model
inpIds = eh.gh.getVarIdByProperty('isInput');
msrIds = eh.gh.getVarIdByProperty('isMeasured');
readingsIdArray = [inpIds msrIds];

inpAliasCell = eh.gh.getAliasById(inpIds);
msrAliasCell = eh.gh.getAliasById(msrIds);
readingsAliasCell = {inpAliasCell{:} msrAliasCell{:}};

fprintf('Input specification:\n');
fprintf('Number of readings: %d (%d inputs, %d measruements)\n',length(inpIds), length(msrIds), length(readingsIdArray));
fprintf('Inputs, in order:\n');
fprintf('%s,',inpAliasCell{:}); fprintf('\n');
fprintf('Measurements, in order:\n');
fprintf('%s,',msrAliasCell{:}); fprintf('\n');

end

