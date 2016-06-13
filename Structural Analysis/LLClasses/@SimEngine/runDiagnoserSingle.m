function [ residuals ] = runDiagnoserSingle( eh )
%RUNDIAGNOSERSINGLE Generate residuals for single evaluations
%   Detailed explanation goes here

debug = true;

% Make sure the readings array exists
ws_vars = evalin('base','who');
if ~ismember('readings',ws_vars)
    error('Missing readings array ''readings''');
end

global readings

if debug fprintf('exptected readings dimensions: (%d,%d)\n',size(eh.readingsIdArray,1),size(eh.readingsIdArray,2)); end
if debug fprintf('Acquired readings dimensions: (%d,%d)\n',size(readings,1),size(readings,2)); end

if size(readings,2)~=length(eh.readingsIdArray)
    error('Readings array column number does not match the number of readings provided by the model');
end

% Make sure the dt exists
if ~ismember('dt',ws_vars)
    error('Missing dt');
end

global dt
eh.dt = dt;

% Create the output array
evalin('base','global evaluations');
s = sprintf('evaluations = nan*ones(%d,%d);', size(readings,1),length(eh.evalIds));
evalin('base',s);
evalin('base','global residuals');
s = sprintf('residuals = nan*ones(%d,%d);', size(readings,1), length(eh.residualIds));
evalin('base',s);

% Get the evaluation order
evaluationOrder = parseMatchingNoCycles(eh.gh);

% Iterate of the available inputs
for i = 1:size(readings,1)
    
    % Reset the variable values
    eh.readingsValues = nan*eh.readingsValues;
    eh.evalValues = nan*eh.evalValues;
    
    % Store the readings
    eh.storeReadings(i);
    
    % Run over the evaluations
    for j = 1:length(evaluationOrder)
        eh.evaluateSingle(evaluationOrder(j))       
    end
    
    % Check if all evaluations and variables have been calculated
    nan_index = isnan(eh.evalValues);
    if any(nan_index)
        error('nan value found in evaluation with ID %d',find(nan(index)))
    end
    nan_index = isnan(eh.residualValues);
    if any(nan_index)
        error('nan value found in residual with ID %d',find(nan(index)))
    end
    
    % Export the iteration results onto the workspace
    eh.exportResults(i, eh.evalValues, eh.residualValues);
   
end


end

