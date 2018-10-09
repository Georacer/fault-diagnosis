function [ stop ] = plotSwarm( inputs, value, state )
%PLOTSWARM Plot the particles of a PSO
%   Detailed explanation goes here

persistent xdata
persistent ydata
persistent zdata

stop = false; % This function does not stop the solver
switch state
    case 'init'
        
        nplot = 2; % We want a 3D plot
        
        markerSize = 10;
        tag = 'maximum_plot';
        ph = scatter3(0,0,0,markerSize,'Tag',tag);
%         zlim([0 50]);
        xlim([20 35]);
        ylim([deg2rad([-45 45])]);
        xlabel('Va_m'); % Iteration number at the bottom
        ylabel('Beta_m');
        title('Particle evaluations')
        xdata = [];
        ydata = [];
        zdata = [];
        ph.XDataSource = 'xdata';
        ph.YDataSource = 'ydata';
        ph.ZDataSource = 'zdata';
        setappdata(gcf,'t0',tic); % Set up a timer to plot only when needed
    case 'iter'
        
        if (value<0)
            return
        end
        
        nplot = 2; % We want a 3D plot
        
        tag = 'maximum_plot';
        plotHandle = findobj(get(gca,'Children'),'Tag',tag); %TODO: enable searching in other figures as well

%         xdata = [plotHandle.XData inputs(1)];
%         ydata = [plotHandle.YData inputs(2)];
%         zdata = [plotHandle.ZData value];
        xdata(end+1) = inputs(1);
        ydata(end+1) = inputs(2);
        zdata(end+1) = value;
%         plotHandle.XData = xdata;
%         plotHandle.YData = ydata;
%         plotHandle.ZData = zdata;

        if toc(getappdata(gcf,'t0')) > 1/30 % If 1/30 s has passed
%           drawnow % Show the plot
          refreshdata(plotHandle, 'caller');
          drawnow
          setappdata(gcf,'t0',tic); % Reset the timer
        end
    case 'done'
        % No cleanup necessary

end