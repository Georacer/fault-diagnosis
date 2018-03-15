function [  ] = plotResidualGrid( pso, x_id, y_id, limits_x, limits_y, values)
%PLOTRESIDUALGRID Plot the cost function of a residual for 2 of its
%variables
%   INPUTS:
%   res_gen : Pointer to a particle-swarm optimizer, corresponding to the
%   residual generator
%   x_id    : The id of the x-variable
%   y_id    : The id of the y-variable
%   limits_x: The x-interval over which to plot
%   limits_y: The y-interval over which to plot
%   values  : A dictionary pre-filled with the rest of the variable and
%   parameter values

% TODO: Implement a 2D fallback

tick_no = 30;
x_ticks = linspace(limits_x(1), limits_x(2), tick_no);
y_ticks = linspace(limits_y(1), limits_y(2), tick_no);

[X, Y] = meshgrid(x_ticks, y_ticks);

function result = evaluation(x,y)
    pso.res_gen.reset_state(); % Reset the residual state
    new_values = [x y];
    values.setValue([x_id, y_id],[], new_values);
    result = pso.residual_evaluation_cost(values); % Evaluate the residual, including the soft-constraints penalty cost
end

Z = arrayfun(@(x,y) evaluation(x,y),X,Y);

figure();
mesh(X,Y,Z);
xlabel('Beta_m');
ylabel('fseq1');

end
