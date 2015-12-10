function [p,q]=PlotDM(SM,eq)
% PlotDM(SM)  Plots a Dulmage-Mendelsohn decomposition
%
%    [row,col] = PlotDM(S [,eq])
%
%  Inputs:
%    SM     - A structural model object.
%             In case S is a structural model object, the 
%             structure of SM.X is plotted.
%
%    eq (optional)
%           - If non-zero, perform canonical decomposition of M+ and
%             plot equivalence classes
%
%             For further details on the canonical decomposition
%             of the M+ part of the structure, see Chapter 4 in 
%             "Design and Analysis of Diagnosis Systems Using Structural 
%              Methods", PhD thesis, Mattias Krysander, 2006. 
%
%  Outputs:
%    row    - row permutation used in the plot
%    col    - column �permutation used in the plot
%
%  See also: CreateSM, GetDMParts, PSODecomposition
%

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2009/03/13

% Copyright (C) 2006,2007,2009 Erik Frisk and Mattias Krysander
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
  
  if nargin < 2
    eq=0;
  end
  
  if isstruct(SM)
    X = SM.X;
  else
    X = SM;
  end
  
  dm = GetDMParts(SM);
  
  if eq && length(dm.Mp.row)>0
    Xp = X(dm.Mp.row,dm.Mp.col);
    P = PSODecomposition(Xp);
    
    prowstart = length(dm.rowp)-length(P.p)+1;
    rowp = dm.Mp.row;
    rowp = rowp(P.p);
    dm.rowp(prowstart:end) = rowp;
    
    pcolstart = length(dm.colp)-length(P.q)+1;
    colp = dm.Mp.col;
    colp = colp(P.q);
    dm.colp(pcolstart:end) = colp;
  end
  spy(X(dm.rowp,dm.colp))
  hold on
  
  %% Plot under determined part
  if length(dm.Mm.row)>0
    r = length(dm.Mm.row);
    c = length(dm.Mm.col);
    x1 = 0.5;
    x2 = x1+c;
    y1 = 0.5;
    y2 = y1+r;
    plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'r')    
  end
  
  %% Plot exactly determined part
  r = 1+length(dm.Mm.row);
  c = 1+length(dm.Mm.col);
  for k=1:length(dm.M0)
    n = length(dm.M0{k}.row);
    x1 = c-0.5;
    x2 = x1+n;
    y1 = r-0.5;
    y2 = y1+n;
    plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'r')
    r = r+n;
    c = c+n;
  end
  
  %% Plot over determined part  
  if length(dm.Mp.row)>0
    nr = length(dm.Mp.row);
    nc = length(dm.Mp.col);
    x1 = c-0.5;
    x2 = x1+nc;
    y1 = r-0.5;
    y2 = y1+nr;
    plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'r')    
  end

  if eq && length(dm.Mp.row)>0
    %% Plot equivalence classes in over determined part  
    r1 = r;
    c1 = c;
    for k=1:length(P.eqclass)
      nr = length(P.eqclass{k}.row);
      nc = length(P.eqclass{k}.col);
      x1 = c-0.5;
      x2 = x1+nc;
      y1 = r-0.5;
      y2 = y1+nr;
%       plot( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'g')
      fill( [x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],0.7*[1 1 1])
      r = r+nr;
      c = c+nc;
    end  
    plot([c1-0.5 length(dm.colp)+0.5], [r-0.5 r-0.5], 'k--')
    plot([c-0.5 c-0.5], [r1-0.5 length(dm.rowp)+0.5], 'k--')   
    spy(X(dm.rowp,dm.colp))
  end
  hold off
  xlabel('Variables');
  ylabel('Equations');
  
if isstruct(SM)
  nx = length(SM.x);
  nf = length(SM.f);
  nz = length(SM.z);
  ne = length(SM.e);  
  % Place the equation labels
  set(gca,'YTick',1:length(SM.e));
  set(gca,'YTickLabel',SM.e(dm.rowp));
  % Place the variable labels
%   Xt = 1:nx+nf+nz;
  Xt = 1:nx;
  Xl = [0 length(Xt)+1];
  set(gca,'XTick',Xt,'XLim',Xl);
  ax = axis; % Current axis limits
  axis(axis); % Fix the axis limits
  Yl = ax(3:4); % Y-axis limits  
  vars = {SM.x{dm.colp}};
  t = text(Xt-0.3,Yl(2)*ones(1,length(Xt))+0.5,vars);
  %set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',45);
  set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);
  set(gca,'XTickLabel','')
end
  
  if nargout>0
    p = dm.rowp;
    q = dm.colp;
  end
  