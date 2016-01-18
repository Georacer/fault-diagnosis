function r = IsHighIndex( model, eq )
% IsHighIndex Is the model of high structural differential index?
%
%   model.IsHighIndex( [eq] )
%
%  Determines if a set of equations are structurally of high index. If no
%  equations are specified, the set defaults to the full model.
%
%  Inputs:
%    eq (optional) - Set of equations (indices)
%
%  Outputs:
%    true if model has high structural index, false otherwise

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  if nargin < 2
    eq = 1:size(model.X,1);
  end

  hod = HighestOrderDerivatives( model, eq );
  r = IsHighIndexDAE( model.X(eq,:), hod);
end

function r=IsHighIndexDAE(X, hod)
  n1 = length( hod.cdX1 );
  n2 = length( hod.cX2 );
  X(X==2)=0;
  X(X==3)=0;
  r = (sprank(X(:,[hod.cdX1', hod.cX2'])) < n1+n2);
end

function hod=HighestOrderDerivatives( model, eq )
  [rX1,cX1] = find(model.X(eq,:)==2);
  n1 = length(cX1);
  n = size(model.X,2);

  cdX1 = zeros(n1,1);
  for k=1:n1
    cdX1(k) = find(model.X(eq(rX1(k)),:)==3);
  end
  [~,c0] = find(all(model.X(eq,:)==0,1)); c0 = c0';
  cX2 = setdiff(1:n,[cX1' cdX1' c0'])';

  hod.rX1  = rX1;
  hod.cX1  = cX1;
  hod.cdX1 = cdX1;
  hod.cX2  = cX2;
end


