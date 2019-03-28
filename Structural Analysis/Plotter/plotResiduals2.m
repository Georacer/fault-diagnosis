function [ ] = plotResiduals2( residual_indices, t_start, t_end, tfault, SA_results, RG_results, RE_results, fault_alias)
%PLOTRESIDUALS Plot the requested residuals
%   Detailed explanation goes here

valid_residual_idx = residual_indices;
plot_tstart = t_start;
plot_tend = t_end;
time_vector = RE_results.time_vector;

plot_idxstart = find(time_vector>=plot_tstart, 1, 'first');
plot_idxend = find(time_vector<plot_tend, 1, 'last');

plot_cols = 2;
plot_rows = 8;
num_plots = length(residual_indices);
num_figs = ceil(num_plots/(plot_cols*plot_rows));

% Build detectablilty matrix
% TODO Currently works only for graphs with only 1 connected subgraph
residual_mask(residual_indices) = 1;
new_res_gens_set = SA_results.res_gens_set{1}(logical(residual_mask));
new_matchings_set = SA_results.matchings_set{1}(logical(residual_mask));
FSStruct = generateFSM(SA_results.gi, {new_res_gens_set}, {new_matchings_set});
% Retrieve fault signature
fault_id = SA_results.gi.getVarIdByAlias(fault_alias);
fault_idx = find(FSStruct.fault_ids==fault_id);
signature = FSStruct.FSM(:,fault_idx);

plot_idx = 1;
for fig_idx = 1:num_figs
    figure();
    plot_counter = 1;
    while plot_counter <= plot_cols*plot_rows
        if plot_idx>num_plots
            break;
        end
        subplot(plot_rows, plot_cols, plot_counter);
        series_idx = valid_residual_idx(plot_idx);
        series = RE_results.residuals(series_idx,:);
        
        plot(time_vector(plot_idxstart:plot_idxend), series(plot_idxstart:plot_idxend));
        grid on
        % Paint sensitive residuals
        color_white = [1 1 1];
        color_orange = [1 0.8 0.6];
        bg_color = color_white;
        if signature(plot_idx)
            bg_color = color_orange; 
        end
        if RG_results.res_gen_cell{series_idx}.solver_errors_occurred
            bg_color = bg_color - [0 0.2 0.2];
        end
        set(gca, 'Color', bg_color);
        % Draw fault line
        line([tfault tfault], [min(series(plot_idxstart:plot_idxend)), max(series(plot_idxstart:plot_idxend))],...
            'LineStyle', '--', 'Color', 'r', 'LineWidth', 1.5);
        % Print residual generator characteristics
        if RG_results.res_gen_cell{series_idx}.contains_dae
            has_dae = 'true';
        else
            has_dae = 'false';
        end
        if RG_results.res_gen_cell{series_idx}.contains_algebraic_scc
            has_scc = 'true';
        else
            has_scc = 'false';
        end
        if RG_results.res_gen_cell{series_idx}.contains_differentiator
            has_diff = 'true';
        else
            has_diff = 'false';
        end
        annotation_string = sprintf('RG#: %d\nDAE: %s\nSCC: %s\nDiff: %s', series_idx, has_dae, has_scc, has_diff);
        text(0.05, 0.6, annotation_string, 'Units', 'normalized', 'FontSize', 6);
        
        plot_counter = plot_counter + 1;
        plot_idx = plot_idx + 1;
    end
    if plot_idx>num_plots
        break;
    end
end

end

