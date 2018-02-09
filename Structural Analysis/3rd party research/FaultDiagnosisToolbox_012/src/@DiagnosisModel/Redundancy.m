function r = Redundancy(model, m)
% REDUNDANCY Compute the structural degree of redundancy of a model
%  
%  r = model.Redundancy( [submodel] )
%
%  Inputs:
%    submodel  - Define which equations to compute redundancy for
%                Default: full model
%  Outputs:
%    r         - Redundancy of the model
%
%  Example:
%    model.Redundancy()     % Computes redundancy of full model
%    model.Redundancy(1:10) % Computes redundancy of the first 10 equations

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if nargin < 2
    m = 1:model.ne;
  end
  
  dm = GetDMParts( model.X(m,:) );
  r = length(dm.Mp.row)-length(dm.Mp.col);      
end
