function [ stop ] = plotSwarm( inputs, value, state )
%PLOTSWARM Plot the particles of a PSO
%   Detailed explanation goes here

stop = false; % This function does not stop the solver
switch state
    case 'init'
        
        nplot = 2; % We want a 3D plot
        
        markerSize = 10;
        tag = 'maximum_plot';
        ph = scatter3(0,0,0,markerSize,'Tag',tag);
        xlabel('Beta_m'); % Iteration number at the bottom
        ylabel('fseq1');
        title('Particle evaluations')
        setappdata(gcf,'t0',tic); % Set up a timer to plot only when needed
    case 'iter'
        nplot = 2; % We want a 3D plot
        
        tag = 'maximum_plot';
        plotHandle = findobj(get(gca,'Children'),'Tag',tag);

        xdata = [plotHandle.XData inputs(1)];
        ydata = [plotHandle.YData inputs(2)];
        zdata = [plotHandle.ZData value];
        plotHandle.XData = xdata;
        plotHandle.YData = ydata;
        plotHandle.ZData = zdata;

        if toc(getappdata(gcf,'t0')) > 1/30 % If 1/30 s has passed
          drawnow % Show the plot
          setappdata(gcf,'t0',tic); % Reset the timer
        end
    case 'done'
        % No cleanup necessary

end