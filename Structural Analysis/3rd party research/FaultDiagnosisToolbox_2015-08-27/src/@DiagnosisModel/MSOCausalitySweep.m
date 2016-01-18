function t = MSOCausalitySweep( model, mso, varargin )
% MSOCausalitySweep  For a given MSO, determine causality for sequential 
%                    residual generator for each n residual equations.
%
%    model.MSOCausalitySweep( mso, options)
%
%  The options are given as key/value pairs as
%
%  Key                Value
%    diffres          Can be 'Int' or 'Der' (default 'Int'). Determines how
%                     to treat differential constraints when used as a
%                     residual equation.
%
%    causality        Can be 'Int' or 'Der'. When causality is specified, 
%                     the call returns a boolean value indicating if it is 
%                     possible to realize the residual generator in
%                     derivative or integral causality respectively. If
%                     this option is given, the diffres key have no
%                     effect.

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  p = inputParser;
  p.addOptional('diffres', 'Int');
  p.addOptional('causality', '');
  p.parse(varargin{:});
  opts = p.Results;

  r = cell(1,length(mso));
  if strcmp(opts.causality, 'Der') && ~strcmp(opts.diffres, 'Der')
    opts.diffres = 'Der';
  elseif strcmp(opts.causality, 'Int') && ~strcmp(opts.diffres, 'Int')
    opts.diffres = 'Int';
  end
  
  for ii=1:length(mso);
    Gamma = model.Matching(setdiff(mso,mso(ii)));

    if ~IsDifferentialConstraint(model.X, mso(ii))
      r{ii} = Gamma.type;
    elseif strcmp(opts.diffres,'Int')
      % Treat differential residual constraint in integral causality
      switch Gamma.type
        case 'Der'
          r{ii} = 'Mixed';
        case {'Int','Mixed'}
          r{ii} = Gamma.type;
        case 'Algebraic'
          r{ii} = 'Int';
        otherwise
          error('Unknown type of matching');
      end
    else % Treat differential residual constraint in derivative causality
      switch Gamma.type
        case 'Int'
          r{ii} = 'Mixed';
        case {'Der','Mixed'}
          r{ii} = Gamma.type;
        case 'Algebraic'
          r{ii} = 'Der';
        otherwise
          error('Unknown type of matching');
      end
    end
  end
  
  if strcmp(opts.causality,'Der') 
    t = any(strcmp('Der', r))||any(strcmp('Algebraic', r));
  elseif strcmp(opts.causality,'Int')
    t = any(strcmp('Int', r))||any(strcmp('Algebraic', r));
  else
    t = r;
  end
end

function r=IsDifferentialConstraint( X, e )
  r = any(X(e,:)==3);
end
