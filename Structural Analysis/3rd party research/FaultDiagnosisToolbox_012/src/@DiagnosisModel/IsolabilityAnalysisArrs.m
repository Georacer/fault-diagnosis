function [im,df,ndf] = IsolabilityAnalysisArrs( model, arrs, varargin )
% IsolabilityAnalysisArrs  Perform structural single fault isolability analysis of a set of ARRs
%
%    [im,df,ndf] = model.IsolabilityAnalysisArrs( arrs, options )  
%
%  With no output arguments, then the command plots the isolability
%  analysis results.
%
%  Options are key/value pairs
%
%  Inputs:
%    arrs     - cell array with sets of equations
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

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  p = inputParser;
  p.addOptional('permute',true);
  p.parse( varargin{:} );
  opts = p.Results;

  % Extract FSM
  fsm = model.FSM( arrs );

  % Compute isolability properties
  [im,df,ndf] = model.IsolabilityAnalysisFSM( fsm, 'permute', false );
  
  % Plot results
  if nargout==0
    if opts.permute
      [p,q] = dmperm(im);
    else
      p = 1:numel(model.f);
      q = p;
    end;
    
    nf = size(model.F,2);
    spy(im(p,q), 40)
    set(gca,'XTick', 1:nf);
    set(gca,'YTick', 1:nf);
    if verLessThan('matlab', '8.4')
      set(gca,'XTickLabel',model.f(p));
      set(gca,'YTickLabel',model.f(p));
    else
      set(gca,'XTickLabel',model.f(p), 'TickLabelInterpreter','none');
      set(gca,'YTickLabel',model.f(p), 'TickLabelInterpreter','none');
    end
    xlabel('')
    if ~isempty(model.name)
      title(sprintf('Isolability matrix for set of ARRs in ''%s''', model.name ))
    else
      title('Isolability matrix for set of ARRs')
    end
  end
end
