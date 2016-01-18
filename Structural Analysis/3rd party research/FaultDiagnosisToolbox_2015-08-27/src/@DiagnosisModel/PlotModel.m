function PlotModel(model)
% PlotModel  Plots a model object

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
   
nx = length(model.x);
nf = length(model.f);
nz = length(model.z);
ne = length(model.e);

X0 = model.X; X0(X0>1)=0;
[rd,cd] = find(model.X==3);
[ri,ci] = find(model.X==2);

spy([X0 zeros(ne,nf) zeros(ne,nz)],'b');
hold on
for k=1:length(rd)
  text(cd(k),rd(k),'D', 'Color', 'blue', 'FontSize', 12,...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
  text(ci(k),ri(k),'I', 'Color', 'blue', 'FontSize', 12,...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
end
spy([zeros(ne,nx) model.F zeros(ne,nz)],'r');
spy([zeros(ne,nx) zeros(ne,nf) model.Z],'k');
hold off

%spy([model.X model.F model.Z]);
set(gca,'YTick',1:length(model.e));
set(gca,'YTickLabel',model.e);

Xt = 1:nx+nf+nz;
Xl = [0 length(Xt)+1];
set(gca,'XTick',Xt,'XLim',Xl);

ax = axis; % Current axis limits
axis(axis); % Fix the axis limits
Yl = ax(3:4); % Y-axis limits

% Place the text labels
vars = {model.x{:},model.f{:},model.z{:}};
t = text(Xt-0.3,Yl(2)*ones(1,length(Xt))+0.5,vars);

%set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',45);
set(t,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);

set(gca,'XTickLabel','')
set(gca,'Xlabel',xlabel(''))
hold on
plot([nx nx]+0.5,[0 ne+0.5],'k--');
plot([nx+nf nx+nf]+0.5,[0 ne+0.5],'k--');
if ~isempty(model.name)
  title(model.name);
end
hold off
