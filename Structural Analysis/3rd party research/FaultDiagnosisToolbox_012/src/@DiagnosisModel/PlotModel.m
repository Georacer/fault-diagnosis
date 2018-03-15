function PlotModel( model, varargin )
% PLOTMODEL  Plots the model structure
%
%  model.PlotModel()
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  p = inputParser;
  p.addOptional('Export_LaTeX',false);
  p.addOptional('Export_fid',-1);
  p.addOptional('axislabels', true);
  p.parse(varargin{:});
  opts = p.Results;

  if ~ischar(opts.Export_LaTeX) && opts.Export_fid==-1
    PlotStructuralModel( model );
  else
    if opts.Export_LaTeX
      fprintf('Exporting structural model to file %s\n', opts.Export_LaTeX);
    end
    LaTeXExportStructuralModel( model, opts.Export_LaTeX, opts.Export_fid );    
  end
end

function LaTeXExportStructuralModel( model, fileName, fid )
  
  if fileName
    fid = fopen(fileName, 'wt');
    if fid==-1
      error('Could not open file %s, exiting...', fileName);
    end
    fprintf(fid, '\\documentclass{standalone}\n');
    fprintf(fid, '\\usepackage{color}\n');
    fprintf(fid, '\\usepackage{amsmath}\n\n');

    fprintf( fid, '%% File generated %s\n\n', datestr(now));

    fprintf(fid, '\\begin{document}\n');
  end
  fprintf(fid, '\\begin{math}\n');
  fprintf(fid, '  \\begin{array}{c|');
  for k=1:model.nx
    fprintf(fid, 'c');
  end
  fprintf(fid, '|');
  for k=1:model.nf
    fprintf(fid, 'c');
  end
  fprintf(fid, '|');
  for k=1:model.nz
    fprintf(fid, 'c');
  end
  fprintf(fid, '}\n');
  
  fprintf(fid, '    ');
  for k=1:model.nx
    if ~isempty(model.x_latex)
      fprintf( fid, '& %s ', model.x_latex{k});
    else
      fprintf( fid, '& %s ', model.x{k});
    end
  end
  for k=1:model.nf
    if ~isempty(model.f_latex)
      fprintf( fid, '& %s ', model.f_latex{k});
    else
      fprintf( fid, '& %s ', model.f{k});
    end
  end
  for k=1:model.nz
    if ~isempty(model.z_latex)
      fprintf( fid, '& %s ', model.z_latex{k});
    else
      fprintf( fid, '& %s ', model.z{k});
    end
  end
  fprintf(fid, '\\\\\n');
  fprintf(fid, '    \\hline\n');

  for k=1:model.ne
    if ~isempty(model.e_latex)
      fprintf( fid, '    %s ', model.e_latex{k});
    else
      fprintf( fid, '    %s ', model.e{k});
    end
    
    for l=1:model.nx
      switch model.X(k,l)
        case 0
          fprintf( fid, '& ');
        case 1
          fprintf( fid, '& {\\color{blue}X} ');
        case 2
          fprintf( fid, '& {\\color{blue}I} ');
        case 3
          fprintf( fid, '& {\\color{blue}D} ');
        otherwise
          fprintf('Ill defined structural model, continue at own risk\n');
          fprintf( fid, '& ');
      end
    end
    for l=1:model.nf
      if model.F(k,l)==0
        fprintf( fid, '& ');
      else
        fprintf( fid, '& {\\color{red}X} ');
      end
    end
    for l=1:model.nz
      if model.Z(k,l)==0
        fprintf( fid, '& ');
      else
        fprintf( fid, '& X ');
      end
    end
    fprintf(fid, '\\\\\n');
  end
    
  fprintf(fid, '  \\end{array}\n');
  fprintf(fid, '\\end{math}\n');
  
  if fileName
    fprintf(fid, '\\end{document}\n');
    fclose( fid );
  end
end

function PlotStructuralModel( model )
  nx = length(model.x);
  nf = length(model.f);
  nz = length(model.z);
  ne = length(model.e);

  X0 = model.X; X0(X0>1)=0;
  [rd,cd] = find(model.X==3);
  [ri,ci] = find(model.X==2);

  spy([X0 zeros(ne,nf) zeros(ne,nz)],'b');
  
  if nx<50
    fontSize = 12;
  elseif nx > 50 && nx < 75
    fontSize = 10;
  else
    fontSize = 8;
  end
  hold on  
  for k=1:length(rd)
    text(cd(k),rd(k),'D', 'Color', 'blue', 'FontSize', fontSize,...
      'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
    text(ci(k),ri(k),'I', 'Color', 'blue', 'FontSize', fontSize,...
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

  if verLessThan('matlab', '8.4')
    set(t,'HorizontalAlignment','right','VerticalAlignment','top','Rotation',90);
  else
    set(t,'HorizontalAlignment','right','VerticalAlignment','top','Rotation',90, ...
        'interpreter', 'none');
  end
  
  set(gca,'XTickLabel','')
  set(gca,'Xlabel',xlabel(''))
  hold on
  plot([nx nx]+0.5,[0 ne+0.5],'k--');
  plot([nx+nf nx+nf]+0.5,[0 ne+0.5],'k--');
  if ~isempty(model.name)
    title(model.name);
  end
  hold off
end

