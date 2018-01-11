function sm = Structural( model )
% Structural  Convert a symbolic model to a structural model
%
%  model2 = model.Structural()
%
%  Important: If no output argument is given, the current
%             object will be modified, i.e., it is allowed to write
%                model.Structural();
%             To create a new object without modifying the original 
%             model, instead write
%                model2 = model.Structural();

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if nargout==0
    sm = model;
  else 
    sm = model.copy();
  end
  sm.type = 'Structural';
  sm.syme = {};
  sm.parameters = {};
end
