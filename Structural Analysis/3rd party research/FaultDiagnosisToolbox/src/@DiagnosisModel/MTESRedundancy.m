function r = MTESRedundancy( model )
% MTESREDUNDANCY Compute the structural degree of redundancy of an MTES set for a model
%  
%  r = model.MTESRedundancy( )
%
%  Outputs:
%    r         - Degree of redundancy for an MTES set
%
%  Example:
%    model.MTESRedundancy()

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

 m = find(any(model.F,2)==0);
 r = model.Redundancy( m ) + 1;
end