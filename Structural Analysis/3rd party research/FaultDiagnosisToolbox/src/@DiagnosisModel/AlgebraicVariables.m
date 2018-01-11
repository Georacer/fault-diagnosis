function [v,idx] = AlgebraicVariables( model )
% AlgebraicVariables  Extract the algebraic variables in the model
%
%   [v,idx] = model.AlgebraicVariables()
%
%  Extract the algebraic variables in the model.
%
%  Outputs:
%    v    Cell array with strings of algebraic variables
%    idx  Array with indices into model.x of algebraic variables

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  idx = setdiff(1:model.nx,find(any(model.X==2,1)));
  v = model.x(idx);
end