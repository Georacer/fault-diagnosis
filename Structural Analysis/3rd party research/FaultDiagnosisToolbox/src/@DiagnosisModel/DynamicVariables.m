function [v,idx] = DynamicVariables( model )
% DynamicVariables  Extract the dynamic variables in the model
%
%   [v,idx] = model.DynamicVariables()
%
%  Extract the dynamic variables in the model.
%
%  Outputs:
%    v    Cell array with strings of dynamic variables
%    idx  Array with indices into model.x of dynamic variables

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  idx = find(any(model.X==2,1));
  v = model.x(idx);
end