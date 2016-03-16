function r = IsPSO( model, eq )
% IsPSO Is the model proper structurally overdetermined?
%
%   model.IsPSO( [eq] )
%
%  Determines if a set of equations is a proper structurally 
%  overdetermined set of equations (PSO). If no
%  equations are specified, the set defaults to the full model.
%
%  Inputs:
%    eq (optional) - Set of equations (indices)
%
%  Outputs:
%    true if model is PSO, false otherwise

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  if nargin < 2
    eq = 1:size(model.X,1);
  end
  dm = GetDMParts(model.X(eq,:));

  if isempty(dm.Mm.row) && isempty(dm.M0)
    r = 1;
  else
    r = 0;
  end 
end




