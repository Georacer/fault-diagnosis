function ms = SubModel( model, eqs, varargin )
% SUBMODEL Extract submodel
%
%  model2 = model.SybModel( eqs, options )
%
%  eqs        Set of indices to equations to keep
%
%  Options can be given as a number of key/value pairs
%
%  Key        Value
%    clear       If true, non used varaibles in the submodel will be
%                eliminated (default: false)
%    verbose     If true, verbose output
%
%             Important: If no output argument is given, the current
%             object will be modified, i.e., it is allowed to write
%                model.SubModel( eqs );
%             To create a new object, the submodel, without
%             modifying the original model, instead write
%                model2 = model.SubModel( eqs );

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  pa = inputParser;
  pa.addOptional( 'clear', false );
  pa.addOptional( 'verbose', false );
  pa.parse(varargin{:});
  opts = pa.Results;

  if nargout==0
    ms = model;
  else 
    ms = model.copy();
  end
  
  if opts.clear
    [~,xIdx] = find(any(ms.X(eqs,:),1));
    [~,fIdx] = find(any(ms.F(eqs,:),1));
    [~,zIdx] = find(any(ms.Z(eqs,:),1));
  else
    xIdx = 1:ms.nx;
    fIdx = 1:ms.nf;
    zIdx = 1:ms.nz;
  end
  
  if opts.verbose && opts.clear
    cxIdx = setdiff(1:ms.nx, xIdx);
    cfIdx = setdiff(1:ms.nf, fIdx);
    czIdx = setdiff(1:ms.nz, zIdx);
    if ~isempty( cxIdx )
      fprintf('  Removing unknown variables: ');
      for k=1:length(cxIdx)
        fprintf('%s ', ms.x{k});
      end
      fprintf('\n');
    end
    if ~isempty( czIdx )
      fprintf('  Removing known variables: ');
      for k=1:length(czIdx)
        fprintf('%s ', ms.z{k});
      end
      fprintf('\n');
    end
    if ~isempty( cfIdx )
      fprintf('  Removing fault variables: ');
      for k=1:length(cfIdx)
        fprintf('%s ', ms.f{k});
      end
      fprintf('\n');
    end
  end
  
  ms.X = ms.X(eqs,xIdx);
  ms.F = ms.F(eqs,fIdx);
  ms.Z = ms.Z(eqs,zIdx);
  ms.e = ms.e(eqs);
  
  ms.x = ms.x(xIdx);
  ms.f = ms.x(fIdx);
  ms.z = ms.x(zIdx);

  if ~isempty(ms.syme)
    ms.syme = ms.syme(eqs);
  end    
end