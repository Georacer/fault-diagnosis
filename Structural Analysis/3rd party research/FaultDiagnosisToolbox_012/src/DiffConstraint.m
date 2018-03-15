function d=DiffConstraint(dvar, ivar)
% DiffConstraint  Specify differential constraint in model
%
%    DiffConstraint(dx,x)
%  
%  Input:
%    dx  -  differentiated varible
%     x  - base variable
%
%  Example:
%    DiffConstraint( 'dx', 'x')
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  d = {dvar,ivar,'diff'};
end