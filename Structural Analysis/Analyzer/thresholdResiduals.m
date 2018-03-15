function [ triggered_residuals ] = thresholdResiduals( RE_results, interval, threshold_norm)
%THRESHOLDRESIDUALS Attempt to threshold batch residual signals
%   INPUTS:
%   RE_results  : Residual Evaluation results, returned by evaluateResiduals()
%   interval    : The indices of the time vector, which define the examination interval
%   threshold_norm: The normalized threshold level (0-1)
%   OUTPUTS:
%   triggered_residuals: A 0-1 array, with 1s in the time samples where residuals were triggered

% Initialize the inputs arguments, if needed
if nargin <2
    interval = [];
end
if isempty(interval)
    interval = 1:size(RE_results.residuals,2);
end

if nargin < 3
    threshold_norm = 0.95;
end

if interval(1)<1
    error('Interval cannot start before the residuals');
end
if interval(end)>size(RE_results.residuals,2)
    error('Interval cannot end after the residuals');
end

% Initialize the ouptut array
triggered_residuals = zeros(size(RE_results.residuals,1), length(interval));

% Iterate over all the residuals
for i=1:size(triggered_residuals,1)
    % If the residual is never triggered:
    if all(abs(RE_results.residuals(i,:))<eps)
        continue;
    end
    % Sort the residual signal
    temp_res = sort(abs(RE_results.residuals(i,:)));
    % Find the threshold% value
    index = floor(length(temp_res)*threshold_norm);
    threshold = temp_res(index);
    for j=1:length(interval) 
        if abs(RE_results.residuals(i,interval(j)))>threshold
            triggered_residuals(i,j) = 1;
        end
    end
end

end

