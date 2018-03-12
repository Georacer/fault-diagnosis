function [ triggered_residuals ] = thresholdResiduals( RE_results, interval, threshold_norm)
%THRESHOLDRESIDUALS Attempt to threshold batch residual signals
%   Detailed explanation goes here

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
    error('Interval cannot be left of residuals');
end
if interval(end)>size(RE_results.residuals,2)
    error('Interval cannot be right of residuals');
end

triggered_residuals = zeros(size(RE_results.residuals,1), length(interval));

for i=1:size(triggered_residuals,1)
    if all(abs(RE_results.residuals(i,:))<eps)
        continue;
    end
    % Sort the residual signal
    temp_res = sort(abs(RE_results.residuals(i,:)));
    % Find the 95% value
    index = floor(length(temp_res)*threshold_norm);
    threshold = temp_res(index);
    for j=1:length(interval) 
        if abs(RE_results.residuals(i,interval(j)))>threshold
            triggered_residuals(i,j) = 1;
        end
    end
end

end

