function sm = ReplaceEquations( model, eqs, reps, xvars, zvars, fvars, params, varargin )
% REPLACEEQUATIONS  Replace existing equations in a given model
%
%  model2 = model.ReplaceEquations( eqs, reps, xvars, zvars, fvars, params, options )
%
%  eqs         Cell array of equations to be added. If model is symbolic,
%              these can be symbolic equations. If the model i structural,
%              this can be cell-arrays with included variables in each
%              equation.
%
%  reps        Indices to the equations that should be replaced by the
%              corresponding equation in eqs.
%
%  xvars       Cell array with names of unknown variables in the equation
%
%  fvars       Cell array with names of fault variables in the equation
%
%  zvars       Cell array with names of known variables in the equation
%
%  parameters  Cell array with names of parameters in the equation
%
%  Options can be given as a number of key/value pairs
%
%  Key        Value
%    xname_latex          Cell array with latex names of unknown variables
%    fname_latex          Cell array with latex names of fault variables
%    zname_latex          Cell array with latex names of known variables
%    parametersname_latex Cell array with latex names of parameters
%
%    Important: If no output argument is given, the current
%      object will be modified, i.e., it is allowed to write
%         model.ReplaceEquations( eqs, reps, xvars, zvars, fvars, params);
%
%      To create a new object, with the replaced equations, without
%      modifying the original model, instead write
%         model2 = model.ReplaceEquations( eqs, xvars, zvars, fvars, params);

% Copyright Erik Frisk, Mattias Krysander, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if nargin < 7
    error('Not enough input arguments');
  end

  if nargout > 0
    sm = model.copy();
  else
    sm = model;  
  end

  pa = inputParser;
  pa.addOptional( 'xname_latex', {} );
  pa.addOptional( 'zname_latex', {} );
  pa.addOptional( 'fname_latex', {} );
  pa.addOptional( 'parameters_latex', {} );
  pa.parse(varargin{:});
  opts = pa.Results;

  if ~isa(eqs,'cell')
    eqs = {eqs};
  end
  
  for kk=1:numel(eqs)  
    eq = eqs{kk};
    if strcmp(model.type,'Symbolic')
      sVar = symvar( eq );
      eqVar = arrayfun( @(v) char(v), sVar, 'UniformOutput', false);
    else
      eqVar = eq;
    end

    % Determine new/existing variables/parameters in the equation
    [~, xNewIdx] = EqVariables( eqVar, xvars, sm.x);
    [~, fNewIdx] = EqVariables( eqVar, fvars, sm.f);
    [~, zNewIdx] = EqVariables( eqVar, zvars, sm.z);
    [~, pNewIdx] = EqVariables( eqVar, params, sm.parameters);

    % Modify incidence matrices X, F, Z
    nxnew = sum(xNewIdx);
    nfnew = sum(fNewIdx);
    nznew = sum(zNewIdx);
    nx = size(sm.X,2);
    nf = size(sm.F,2);
    nz = size(sm.Z,2);
    ne = size(sm.X,1);

    % Modify variable/parameter name arrays
    sm.x = [sm.x eqVar(xNewIdx)];
    sm.f = [sm.f eqVar(fNewIdx)];
    sm.z = [sm.z eqVar(zNewIdx)];
    sm.parameters = [sm.parameters eqVar(pNewIdx)];

    % Determine structure of new equation
    [~, xIdx] = eq2struc(eqVar,sm.x);
    [~, zIdx] = eq2struc(eqVar,sm.z);
    [~, fIdx] = eq2struc(eqVar,sm.f);

    if nxnew>0
      sm.X = [sm.X zeros(ne,nxnew)];
    end
    sm.X(reps(kk),:) = zeros(1,nx+nxnew); sm.X(end,xIdx>0) = 1;

    if nfnew>0
      sm.F = [sm.F zeros(ne,nfnew)];
    end
    sm.F(reps(kk),:) = zeros(1,nf+nfnew); sm.F(end,fIdx>0) = 1;

    if nznew>0
      sm.Z = [sm.Z zeros(ne,nznew)];
    end
    sm.Z(reps(kk),:) = zeros(1,nz+nznew); sm.Z(end,zIdx>0) = 1;

    if strcmp(model.type,'Symbolic')
      % Add symbolic equation
      sm.syme{reps(kk)} = eq;
    end

    % Add Latex-versions of variable/parameter names
    if ~isempty(sm.x_latex)
      if isempty(opts.x_latex)
        for k=1:nxnew
          sm.x_latex{end+1} = eqVar(xNewIdx);
        end
      else
        [~,idx] = ismember(eqVar(xNewIdx),xvars);
        sm.x_latex = [sm.x_latex opts.x_latex(idx)];
      end
    end
    if ~isempty(sm.z_latex)
      if isempty(opts.z_latex)
        for k=1:nznew
          sm.z_latex{end+1} = eqVar(zNewIdx);
        end
      else
        [~,idx] = ismember(eqVar(zNewIdx),zvars);
        sm.z_latex = [sm.z_latex opts.z_latex(idx)];
      end
    end
    if ~isempty(sm.f_latex)
      if isempty(opts.f_latex)
        for k=1:nfnew
          sm.f_latex{end+1} = eqVar(fNewIdx);
        end
      else
        [~,idx] = ismember(eqVar(fNewIdx),fvars);
        sm.f_latex = [sm.f_latex opts.f_latex(idx)];
      end
    end
    if ~isempty(sm.parameters_latex)
      if isempty(opts.parameters_latex)
        for k=1:nxnew
          sm.parameters_latex{end+1} = eqVar(pNewIdx);
        end
      else
        [~,idx] = ismember(eqVar(pNewIdx),params);
        sm.parameters_latex = [sm.parameters_latex opts.parameters_latex(idx)];
      end
    end
  end
end

function [xIdx, xNewIdx] = EqVariables( eqVar, xvar, xvarmod )
  % Check that all variables are included in the model o  
  [isMem, idx] = ismember(eqVar, [xvarmod xvar]);
  
  xIdx = isMem & idx <= numel(xvarmod);
  xNewIdx = isMem & idx > numel(xvarmod);
end


function [xMember, xIdx] = eq2struc( sVar, x)  
  n = numel( sVar );
  xIdx = zeros(1,n);
  xMember = zeros(1,n);
  for k=1:n
    [xMember(k),xIdx(k)]=ismember(char(sVar(k)),x);
  end
end
