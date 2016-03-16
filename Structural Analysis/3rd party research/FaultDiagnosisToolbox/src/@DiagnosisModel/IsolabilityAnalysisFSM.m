function [im,df,ndf] = IsolabilityAnalysisFSM( model, fsm, varargin )
% IsolabilityAnalysisFSM  Perform structural isolability analysis of a Fault Signature Matrix (FSM)
%
%    [im,df,ndf] = model.IsolabilityAnalysisFSM( fsm, options )  
%
%  With no output arguments, then the command plots the isolability
%  analysis results.
%
%  Options are key/value pairs
%
%  Inputs:
%    fsm     - Fault signature matriux
%
%  Key        Value
%    permute    If true, permute the fault variables such that the
%               isolability matrix gets a block structure for easier
%               interpretation when plotted. Does not affect the output 
%               argument im, only the plot (default true)
%
%  
%  Outputs:
%    im       - Isolability matrix, im(i,j)=1 if fault i can be isolated
%               from fault j, 0 otherwise
%    df       - Detectable faults
%    ndf      - Non-detectable faults
%
  p = inputParser;
  p.addOptional('permute',true);
  p.parse( varargin{:} );
  opts = p.Results;

  
  % Compute isolability matrix
  nf = size(fsm,2);
  nr = size(fsm,1);
  im = ones( nf, nf );
  
  for k=1:nr
    im(fsm(k,:)>0,fsm(k,:)==0)=0;
  end

  % Compute detectable and non-detectable faults
  ndf = model.f(any(fsm,1)==0);
  df  = model.f(any(fsm,1)>0);
  
  % Plot
  if nargout==0
    if opts.permute
      [p,q] = dmperm(im);
    else
      p = 1:numel(model.f);
      q = p;
    end;
    
    spy(im(p,q), 40)
    set(gca,'XTick', 1:nf);
    set(gca,'YTick', 1:nf);
    set(gca,'XTickLabel',model.f(p));
    set(gca,'YTickLabel',model.f(p));
    xlabel('')
    if ~isempty(model.name)
      title(sprintf('Isolability matrix for a given FSM in ''%s''', model.name ))
    else
      title('Isolability matrix for a given FSM')
    end
  end
end
