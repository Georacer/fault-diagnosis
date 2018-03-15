function [ ] = plotFaultOccurence( SA_results, candidate_fault_ids, interval, sample_mask )
%PLOTFAULTOCCURENCE Generate the Fault Occurrence Grid
%   INPUTS:
% SA_results            : Structural Analysis results, generated from structural_analysis()
% candidate_fault_ids   : Sets containing fault IDs to be plotted. Has one set for each time sample
% interval              : Time interval over which to generate the plot
% sample_mask           : Select for which samples within the time interval the faults will be plotted

if nargin < 4
    sample_mask = ones(size(interval));
end

% Flatten all the faulty ids
ids_flattened = [];
for i=1:length(candidate_fault_ids)
    ids_flattened = [ids_flattened candidate_fault_ids{i}];
end
ids_flattened = unique(ids_flattened);

% Get the expressions, use them as fault labels
fault_equations = SA_results.gi.getEquations(ids_flattened);
expressions_flattened = SA_results.gi.getExpressionById(fault_equations);

% Setup subsystem colors, hardcoded to the g033 MAVLink model subsystems
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

thickness = 1;
% Initialize the graph block arrays
X_arg = [];
Y_arg = [];
C_arg = [];

counter = 1;
% Iterate over the time samples
for i=1:length(candidate_fault_ids)
    % Check if this time sample is to be plotted
    if ~sample_mask(i)
        continue;
    end
    % For each fault to be plotted in this time sample
    for j=1:length(candidate_fault_ids{i})
        id = candidate_fault_ids{i}(j);
        id_index = find(ismember(ids_flattened,id)); % Find the row where this fault is to be plotted in
        if isempty(id_index)
            continue;
        end
        
        % Create the rectangle representing this fault at this time sample
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

% Generate the patch figure
h2 = figure();
patch(X_arg,Y_arg,C_arg);
xlabel('timestamps (zeroed)');
xlim([interval(1) interval(end)+1])
yticks(linspace(thickness/2, length(expressions_flattened)+thickness/2-1,length(expressions_flattened)));
yticklabels(expressions_flattened);
ylim([0 length(expressions_flattened)+thickness/2]);
set(gca,'TickLabelInterpreter','none');

grid on

end

