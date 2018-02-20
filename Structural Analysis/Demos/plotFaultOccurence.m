function [ ] = plotFaultOccurence( SA_results, candidate_fault_ids, interval )
%PLOTFAULTOCCURENCE Summary of this function goes here
%   Detailed explanation goes here

% % Find the offending expressions
% candidate_faulty_expressions = cell(size(candidate_fault_ids));
% for i=1:length(candidate_fault_ids)
%     fault_equ_ids = SA_results.gi.getEquations(candidate_fault_ids{i});
%     candidate_faulty_expressions{i} = SA_results.gi.getExpressionById(fault_equ_ids);
% end
%
% % Find the offending subsystems
% candidate_faulty_subsystems = cell(size(candidate_fault_ids));
% for i=1:length(candidate_fault_ids)
%     equ_ids = SA_results.gi.getEquations(candidate_fault_ids{i});
%     candidate_faulty_subsystems{i} = SA_results.gi.getSubsystems(equ_ids);
% end
%
% % Gather all the faulty expressions
% expressions_flattened = {};
% for i=1:length(candidate_faulty_expressions)
%     expressions_flattened = [expressions_flattened; candidate_faulty_expressions{i}];
% end
% expressions_flattened = unique(expressions_flattened);

% Flatten all the faulty ids
ids_flattened = [];
for i=1:length(candidate_fault_ids)
    ids_flattened = [ids_flattened candidate_fault_ids{i}];
end
ids_flattened = unique(ids_flattened);

% Get the expressions for use as labels
fault_equations = SA_results.gi.getEquations(ids_flattened);
expressions_flattened = SA_results.gi.getExpressionById(fault_equations);

% Setup subsystem colors
clr_yellow = [1 1 0];
clr_red = [1 0 0];
clr_blue = [0 0 1];
clr_green = [0 1 0];
clr_black = [0 0 0];
clr_sensors = clr_yellow;
clr_autopilot = clr_red;
clr_navigation = clr_blue;
clr_default = clr_green;
clr_os = clr_black;

% Draw an interval graph to inpspect the timestamp intervals
thickness = 1;
X_arg = [];
Y_arg = [];
C_arg = [];
% Iterate within the interval
counter = 1;
for i=1:length(candidate_fault_ids)
    for j=1:length(candidate_fault_ids{i})
        id = candidate_fault_ids{i}(j);
        %         expression = SA.gi.getExpression(ids);
        id_index = find(ismember(ids_flattened,id));
        
        X_arg(1:2,counter) = interval(i);
        X_arg(3:4,counter) = interval(i)+1;
        Y_arg([1 4],counter) = id_index;
        Y_arg([2 3],counter) = id_index-thickness;
        
        % Pick the fault color
        equ_id = SA_results.gi.getEquations(id);
        subsystem = SA_results.gi.getSubsystems(equ_id);
        if isempty(subsystem{1})
            C_arg(counter, 1, :) = clr_default;
        else
            
            switch subsystem{1}
                case 'autopilot'
                    C_arg(counter, 1, :) = clr_autopilot;
                case 'sensors'
                    C_arg(counter, 1, :) = clr_sensors;
                case 'navigation'
                    C_arg(counter, 1, :) = clr_navigation;
                case 'os'
                    C_arg(counter, 1, :) = clr_os;
                otherwise
                    error('Unknown subsystem %s met',subsystem{1});
            end
        end
        counter = counter + 1;
    end
end

h2 = figure();
patch(X_arg,Y_arg,C_arg);
xlabel('timestamps (zeroed)');
xlim([interval(1) interval(end)+1])
yticks(linspace(thickness/2, length(expressions_flattened)+thickness/2-1,length(expressions_flattened)));
yticklabels(expressions_flattened);
set(gca,'TickLabelInterpreter','none');

grid on

end

