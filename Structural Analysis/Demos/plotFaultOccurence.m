function [ ] = plotFaultOccurence( candidate_faulty_expressions, interval )
%PLOTFAULTOCCURENCE Summary of this function goes here
%   Detailed explanation goes here

% Gather all the faulty expressions
expressions_flattened = {};
for i=1:length(candidate_faulty_expressions)
    expressions_flattened = [expressions_flattened; candidate_faulty_expressions{i}]; 
end
expressions_flattened = unique(expressions_flattened);

% Draw an interval graph to inpspect the timestamp intervals
thickness = 1;
X_arg = [];
Y_arg = [];
% Iterate within the interval
counter = 1;
for i=1:length(candidate_faulty_expressions)
    for j=1:length(candidate_faulty_expressions{i})
        expression = candidate_faulty_expressions{i}{j};
        expression_index = find(ismember(expressions_flattened,expression));

        X_arg(1:2,counter) = interval(i);
        X_arg(3:4,counter) = interval(i)+1;
        Y_arg([1 4],counter) = expression_index;
        Y_arg([2 3],counter) = expression_index-thickness;
        counter = counter + 1;
    end
end

h2 = figure();
patch(X_arg,Y_arg,'b');
xlabel('timestamps (zeroed)');
xlim([interval(1) interval(end)+1])
yticks(linspace(thickness/2, length(expressions_flattened)+thickness/2-1,length(expressions_flattened)));
yticklabels(expressions_flattened);
set(gca,'TickLabelInterpreter','none');

grid on

end

