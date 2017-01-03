function t = MSOCausalitySweep( model, mso, varargin )
% MSOCausalitySweep  For a given MSO set, determine causality for sequential 
%                    residual generator for each n residual equations.
%
%    model.MSOCausalitySweep( mso, options)
%
%  The options are given as key/value pairs as
%
%  Key                Value
%    diffres          Can be 'int' or 'der' (default 'int'). Determines how
%                     to treat differential constraints when used as a
%                     residual equation.
%
%    causality        Can be 'int' or 'der'. When causality is specified, 
%                     the call returns a boolean vector indicating if it is 
%                     possible to realize the residual generator in
%                     derivative or integral causality respectively with the
%                     corresponding equations as residual equation. If
%                     this option is given, the diffres key have no
%                     effect.

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  p = inputParser;
  p.addOptional('diffres', 'int');
  p.addOptional('causality', '');
  p.addOptional('quiet', false);
  p.parse(varargin{:});
  opts = p.Results;

  r = cell(1,length(mso));
  if strcmp(opts.causality, 'der') && ~strcmp(opts.diffres, 'der')
    opts.diffres = 'der';
  elseif strcmp(opts.causality, 'int') && ~strcmp(opts.diffres, 'int')
    opts.diffres = 'int';
  end
  
  for ii=1:length(mso);
    Gamma = model.Matching(setdiff(mso,mso(ii)));

    if ~IsDifferentialConstraint(model.X, mso(ii))
      r{ii} = Gamma.type;
    elseif strcmp(opts.diffres,'int')
      % Treat differential residual constraint in integral causality
      switch Gamma.type
        case 'der'
          r{ii} = 'mixed';
        case {'int','mixed'}
          r{ii} = Gamma.type;
        case 'algebraic'
          r{ii} = 'int';
        otherwise
          error('Unknown type of matching');
      end
    else % Treat differential residual constraint in derivative causality
      switch Gamma.type
        case 'int'
          r{ii} = 'mixed';
        case {'der','mixed'}
          r{ii} = Gamma.type;
        case 'algebraic'
          r{ii} = 'der';
        otherwise
          error('Unknown type of matching');
      end
    end
  end
  
  if strcmp(opts.causality,'der') 
    t = strcmp('der', r)|strcmp('algebraic', r);
  elseif strcmp(opts.causality,'int')
    t = strcmp('int', r)|strcmp('algebraic', r);
  else
    t = r;
  end
end

function r=IsDifferentialConstraint( X, e )
  r = any(X(e,:)==3);
end
