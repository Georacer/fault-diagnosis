function PlotSM(SM)
% PlotSM(SM)  Plots a structural model object
%
%    PlotSM(SM)
%
%  Inputs:
%    SM     - A structural model object
%
%  See also: CreateSM
%

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01
%           0.2, Date: 2007/09/01

% Copyright (C) 2006,2007 Erik Frisk and Mattias Krysander
%
% This file is part of SensPlaceTool.
% 
% SensPlaceTool is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% SensPlaceTool is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%   
% You should have received a copy of the GNU General Public License
% along with SensPlaceTool; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

nx = length(SM.x);
nf = length(SM.f);
nz = length(SM.z);
ne = length(SM.e);

spy([SM.X SM.F SM.Z],'x');
set(gca,'YTick',1:length(SM.e));
set(gca,'YTickLabel',SM.e);

Xt = 1:nx+nf+nz;
Xl = [0 length(Xt)+1];
set(gca,'XTick',Xt,'XLim',Xl);

ax = axis; % Current axis limits
axis(axis); % Fix the axis limits
Yl = ax(3:4); % Y-axis limits

% Place the text labels
vars = {SM.x{:},SM.f{:},SM.z{:}};
t = text(Xt-0.3,Yl(2)*ones(1,length(Xt))+0.5,vars);

%set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',45);
set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);

set(gca,'XTickLabel','')
set(gca,'Xlabel',xlabel(''))
hold on
plot([nx nx]+0.5,[0 ne+0.5],'--');
plot([nx+nf nx+nf]+0.5,[0 ne+0.5],'--');
title(SM.name);
hold off
