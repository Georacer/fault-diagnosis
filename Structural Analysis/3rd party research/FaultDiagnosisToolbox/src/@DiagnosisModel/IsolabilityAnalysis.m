function [im,df,ndf] = IsolabilityAnalysis(model, varargin)  
% IsolabilityAnalysis  Perform structural isolability analysis of model
%
%    [im,df,ndf] = model.IsolabilityAnalysis( options )  
%
%  With no output arguments, then the command plots the isolability
%  analysis results.
%
%  Options are key/value pairs
%
%  Key        Value
%    permute    If true, permute the fault variables such that the
%               isolability matrix gets a block structure for easier
%               interpretation when plotted. Does not affect the output 
%               argument im, only the plot (default true)
%
%    causality  Can be 'mixed' (default), 'int', or 'der' for mixed,
%               integral, or derivative causality analysis respectively.
%               See 
%
%                 Frisk, E., Bregon, A., Aaslund, J., Krysander, M., 
%                 Pulido, B., Biswas, G., "Diagnosability analysis
%                 considering causal interpretations for differential
%                 constraints", IEEE Transactions on Systems, Man and 
%                 Cybernetics, Part A: Systems and Humans, 2012, 42(5), 
%                 1216-1229.  
%  
%  Outputs:
%    im       - Isolability matrix, im(i,j)=1 if fault i can be isolated
%               from fault j, 0 otherwise
%    df       - Detectable faults
%    ndf      - Non-detectable faults
%
% Examples:
%   Plot isolability analysis in integral causality
%     model.IsolabilityAnalysis('causality', 'int') 
%
%  Obtain isolability analysis in mixed causality without plotting
%    [im,df,ndf] = model.IsolabilityAnalysis()  

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  p = inputParser;
  p.addOptional('permute',true);
  p.addOptional('causality','mixed');
  p.addOptional('Export_LaTeX', false );
  p.addOptional('Export_fid', -1 );
  p.parse(varargin{:});
  opts = p.Results;
    
  if strcmp(opts.causality,'mixed')
    Mplusfun=@computeMixed;
  elseif strcmp(opts.causality,'der')
    Mplusfun=@computeDeriv;
  elseif strcmp(opts.causality,'int')
    Mplusfun=@computeInteg;
  else
    error('Incorrect causality specification');
  end

  nf = length(model.f);
  ne = size(model.X,1);
  
  % Determine non-detectable faults
  feq = arrayfun(@(fi) find(model.F(:,fi)>0),1:nf);
  dm = Mplusfun( model.X );
  ndrows = setdiff(1:ne,dm.row);
  ndf = model.f(ismember(feq,ndrows)==1);
  df = model.f(ismember(feq,ndrows)~=1);

  im = ones(nf,nf);
  
  for f1=1:nf
    % Decouple fault f1
    f1eqs=find(model.F(:,f1)==0);
    X = model.X(f1eqs,:);
    G = Mplusfun(X);
    im(any(model.F(f1eqs(G.row),:),1),f1)=0;
  end
  
  if ~ischar(opts.Export_LaTeX) && opts.Export_fid==-1 && nargout==0
    PlotIsolabilityAnalysis(model, im, opts);
  elseif ischar(opts.Export_LaTeX) || opts.Export_fid~=-1
    ExportIsolabilityAnalysis(model, im, opts);
  end
end
  
function ExportIsolabilityAnalysis(model, im, opts)
  fileName = opts.Export_LaTeX;
  fid = opts.Export_fid;
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

  if opts.permute
    [p,q] = dmperm(im);
  else
    p = 1:numel(model.f);
    q = p;
  end;

  fprintf(fid, '\\begin{math}\n');
  fprintf(fid, '  \\begin{array}{|c|');
  for k=1:model.nf
    fprintf(fid, 'c|');
  end
  fprintf( fid, '}\n');
  fprintf( fid, '  \\hline\n');
  fprintf( fid, '  ' );
  for k=1:model.nf
    if ~isempty(model.f_latex)
      fprintf(fid, ' & %s', model.f_latex{k});
    else
      fprintf(fid, ' & %s', model.f{k});
    end
  end
  fprintf( fid, '\\\\ \\hline\n');
  
  for k=1:model.nf
    fprintf( fid, '  ' );
    if ~isempty(model.f_latex)
      fprintf(fid, ' %s ', model.f_latex{p(k)});
    else
      fprintf(fid, ' %s ', model.f{p(k)});
    end
    
    for l=1:model.nf
      if im(p(k),q(l))>0
        fprintf(fid, ' & X ');
      else
        fprintf(fid, ' &   ');
      end
    end    
    fprintf( fid, '\\\\ \\hline\n');
  end
  fprintf(fid, '  \\end{array}\n');
  fprintf(fid, '\\end{math}\n');
  
  if fileName
    fprintf(fid, '\\end{document}\n');
    fclose( fid );
  end

end

function PlotIsolabilityAnalysis(model, im, opts)
  nf = length(model.f);
  if opts.permute
    [p,q] = dmperm(im);
  else
    p = 1:numel(model.f);
    q = p;
  end;

  spy(im(p,q), 40)
  set(gca,'XTick', 1:nf);
  set(gca,'YTick', 1:nf);
  set(gca,'XTickLabel',model.f(p), 'TickLabelInterpreter','none');
  set(gca,'YTickLabel',model.f(p), 'TickLabelInterpreter','none');
  xlabel('')
  if ~isempty(model.name)
    titleString = sprintf('Isolability matrix for ''%s''', model.name );
  else
    titleString = 'Isolability matrix';
  end

  if strcmp(opts.causality,'der')
    titleString = sprintf('%s (derivative causality)', titleString);
  elseif strcmp(opts.causality,'int')
    titleString = sprintf('%s (integral causality)', titleString);
  end
  title( titleString );
end  
