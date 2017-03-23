function sm = RemoveFaultVariables( model, fvars )
% REMOVEFAULTVARIABLES  Remove faults from a model
%
%  model2 = model.RemoveFaultVariables( fvars )
%
%  fvars       Cell array with names of fault variables in the equation
%
%    Important: If no output argument is given, the current
%      object will be modified, i.e., it is allowed to write
%         model.RemoveFaultVariables( fvars );
%
%      To create a new object, with the new equations, without
%      modifying the original model, instead write
%         model2 = model.RemoveFaultVariables( fvars );

% Copyright Erik Frisk, Mattias Krysander, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  if nargin < 2
    error('Not enough input arguments');
  end

  if nargout > 0
    sm = model.copy();
  else
    sm = model;  
  end

  if isa(fvars,'char')
    fvars = {fvars};
  end
  [~,fIdx] = ismember(fvars,model.f);
  fIdx = setdiff(1:model.nf,fIdx);
  sm.F = sm.F(:,fIdx);
  sm.f = sm.f(fIdx);
  if ~isempty(sm.f_latex)
    sm.f_latex = sm.f_latex(fIdx);
  end
end
