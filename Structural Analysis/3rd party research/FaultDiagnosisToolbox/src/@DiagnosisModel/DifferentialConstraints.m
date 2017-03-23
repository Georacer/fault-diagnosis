function [diffEqs, stateVars, diffVars] = DifferentialConstraints( model )
% DIFFERENTIALCONSTRAINTS Extract indices to differential constraints and variables in the model 
% 
%   [diffEqs, stateVars, diffVars] = model.DifferentialConstraints()
% 
% Extracts indices to differential constraints and variables in the model 
% 
%    diffEqs          Indices to differential constraints in the model
%    stateVars        Indices to corresponding state variables
%    diffVars         Indices to derivatives of the state variables
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  diffEqs = find(any(model.X==3,2));
  stateVars = arrayfun(@(e) find(model.X(e,:)==2), diffEqs);
  diffVars = arrayfun(@(e) find(model.X(e,:)==3), diffEqs);
end
