function evaluateSingle( eh, edgeId )
%EVALUATESINGLE Evaluate a single function for one of its variables
%   Detailed explanation goes here

% Parse the I/O IDs
equId = eh.gh.getEquations(edgeId);
varId_result = eh.gh.getVariables(edgeId);
varIds_required = setdiff(eh.gh.getVariables(equId),varId_result);

% Check if the required variables are available
for i = 1:length(varIds_required)
    if ~eh.isAvailable(varIds_required(i))
        error('Required variable is not available');
    end
end

% Create the input argument vector
argumentCell = cell(1,length(varIds_required));
for i=1:length(argumentCell)
    argumentCell{i} = eh.getValue(varIds_required(i));
end

% Evalueate the operation
if ismember(varId_result,eh.residualIds)
    result = argumentCell{1} - eh.evaluate(equId, varIds_required(1), argumentCell(2:end));
else
    result = eh.evaluate(equId, varId_result, argumentCell);
end
eh.setValue(varId_result, result);

end

