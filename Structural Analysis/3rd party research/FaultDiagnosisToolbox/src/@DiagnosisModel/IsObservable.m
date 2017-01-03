function obs=IsObservable( model, eq )
% ISOBSERVABLE Determine if a model is structurally observable
% 
%   r = model.IsObservable( [eq] )
% 
% Returns true if a model is structurally observable
% 
%    eq   The set of equations to test for observability. Optional,
%         defaults to all equations.
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)


  if nargin < 2
    eq = 1:model.ne;
  end

  model2 = model.SubModel(eq, 1:model.nx);
  
  [diffEqs, x1Idx, dx1Idx] = DifferentialConstraints( model2 );
  x1Idx = x1Idx'; dx1Idx = dx1Idx'; 
  x2Idx = setdiff(1:model2.nx,[x1Idx dx1Idx]);
  algEqs = setdiff(1:model2.ne, diffEqs);
  
%  x1Idx = sort(x1Idx);
%  x2Idx = sort(x2Idx);
%  dx1Idx = sort(dx1Idx);
%  algEqs = sort(algEqs);

  n1 = numel(x1Idx);
  n2 = numel(x2Idx);
  n = model2.nx;
  m = size(model2.X,1);
  nalg = numel(algEqs);

  % Model format:
  % x1' = dx1
  % 0   = A11 x1 + A12 x2 + A13 dx1
  A = sparse(model2.X(algEqs,[x1Idx x2Idx dx1Idx])); 
  A11 = A(:,1:n1); A12 = A(:,n1+1:n1+n2); A13 = A(:,n1+n2+1:2*n1+n2);

  obs = false;
  
  % Condition 1: Regularity test
  obs = sprank([A11|A13 A12])==(n1+n2);
  
  % Condition 2: rank([A;C]) = n
  if obs
    AC = [zeros(n1,n1+n2) eye(n1);A];
    F = [eye(n1) zeros(n1,n1+n2);zeros(m-n1,n1+n2+n1)];

    G2 = structuralMatrix(AC);
    obs = sprank(G2) == (2*n1+n2);
    if obs
      % Condition 3: rank([A-sF;C]) = n for all s \in C, s neq 0
      G3 = structuralMatrix(AC,F);
      [p,q,r,s,~, ~] = dmperm(G3);
      G = G3(p,q);
      blocks = length(r)-1;
      i = 1;
      if r(blocks+1)-r(blocks)>s(blocks+1)-s(blocks)
        blocks = blocks-1;
      end

      while obs & i<=blocks
        obs = isempty(find(G(r(i):r(i+1)-1,s(i):s(i+1)-1)==2));
        i = i+1;
      end
    end
  end
end

function sm = structuralMatrix(m,n)
  [i,j] = find(m);
  [r,k] = size(m);
  sm = sparse(i,j,1,r,k);

  if nargin>1
    [i,j] = find(n);
    smd = sparse(i,j,2,r,k);
    sm = max(sm,smd);
  end
end

% Old code that didn't work
%   else
%     extObsMatrix = sparse((n-1)*m,n*(n-1)+n1);
%     for k=1:n-1
%       extObsMatrix((k-1)*m+1:(k-1)*m+nalg,(k-1)*n+1:k*n) = A;
%       extObsMatrix(k*m-n1+1:k*m,(k-1)*n+n1+n2+1:(k-1)*n+n1+n2+2*n1) = sparse([-eye(n1) eye(n1)]);
%     end
%     obs = (sprank(extObsMatrix)==n*(n-1)+n1);
%   end
