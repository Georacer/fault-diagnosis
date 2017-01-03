function PlotMatching( model, Gamma )
% PlotMatching  Plots a matching
%
%    model.PlotMatching( Gamma )
%
%  Plots a matching by plotting the structure in an upper-triangular
%  incidence matrix with the matched variables in the diagnoal
%  
%  Input:
%    Gamma - A matching computed by the Matching class method
%
%  Example:
%
%    Gamma = model.Matching( eqs )
%    model.PlotMatching( Gamma )

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  g.row = [];
  g.col = [];
  for k=1:length(Gamma.matching)
    g.row = [g.row Gamma.matching{k}.row];
    g.col = [g.col Gamma.matching{k}.col];
  end
  % Make plot upper triangular
  g.row = fliplr(g.row);
  g.col = fliplr(g.col);
  
  X0 = model.X(g.row,g.col); X0(X0>1)=0;

  [rd,cd] = find(model.X(g.row,g.col)==3);
  [ri,ci] = find(model.X(g.row,g.col)==2);

  spy(X0,'b');
  for k=1:length(rd)
    text(cd(k),rd(k),'D', 'Color', 'blue', 'FontSize', 12,...
      'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    text(ci(k),ri(k),'I', 'Color', 'blue', 'FontSize', 12,...
      'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
  end
  
  set(gca,'YTick',1:length(g.row));
  set(gca,'YTickLabel',model.e(g.row)); 
  
  Xt = 1:length(g.col);
  Xl = [0 length(Xt)+1];
  set(gca,'XTick',Xt,'XLim',Xl);

  ax = axis; % Current axis limits
  axis(axis); % Fix the axis limits
  Yl = ax(3:4); % Y-axis limits

  % Place the text labels
  vars = {model.x{g.col}};
  t = text(Xt-0.1,Yl(2)*ones(1,length(Xt))+0.2,vars);
  if verLessThan('matlab', '8.4')
    set(t,'HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);
  else
    set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);
  end
  

  set(gca,'XTickLabel','')
  set(gca,'Xlabel',xlabel(''))

  % Draw lines for Hall components
  hold on
  n = length(g.col);
  for k=1:length(Gamma.matching)
    d = length(Gamma.matching{k}.row);
    PlotBox(n-d+1,n-d+1,n,n);
    n = n-d;
  end
  hold off
  
  if ~isempty(model.name)
    title(sprintf('Matching (%s) of size %d in model: %s', Gamma.type, length(g.col), model.name))
  else
    title(sprintf('Matching (%s) of size %d', Gamma.type, length(g.col)));
  end
end

function [cx,cy] = PlotBox(x1,y1,x2,y2)
  cx = [x1-0.5 x1-0.5 x2+0.5 x2+0.5 x1-0.5];
  cy = [y1-0.5, y2+0.5 y2+0.5 y1-0.5 y1-0.5];
  plot( cx, cy, 'k' );
end

