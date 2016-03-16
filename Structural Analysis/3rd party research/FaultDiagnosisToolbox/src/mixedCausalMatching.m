function [Gamma,s] = mixedCausalMatching(X)
% mixedCausalMatching  Compute a causal matching using mixed causality
%
%    [Gamma,s] = mixedCausalMatching(X)
%
%  Inputs:
%    X        - An incidence matrix
%
%  Output:
%   Gamma     - 
%   s         - 

  % check input
  n = size(X);
  dm = GetDMParts(X);
  if length(dm.M0eqs)~=n(1) || length(dm.M0vars)~=n(2)
      error('The input should be just-determined');
  end

  % init
  G.X = X;
  n = size(X);
  G.row = 1:n(1);
  G.col = 1:n(2);
  Gamma = full(sparse([],[],[],0,2));

  % Compute a e \in A(G)\cap Ei 
  [E,found] = admissibleEdges(G);
  while found
      % Gamma = Gamma U \{e\}
      Gamma(end+1,:) = E;

      % G = G - M({e}) - X({e})
      r = find(G.row==E(1));
      c = find(G.col==E(2));
      G.row = G.row([1:r-1 r+1:end]);
      G.col = G.col([1:c-1 c+1:end]);
      G.X = G.X([1:r-1 r+1:end],[1:c-1 c+1:end]);

      % Compute a e \in A(G)\cap Ei 
      [E,found] = admissibleEdges(G);
  end
  if size(Gamma,1)>0
      s{1}.row = Gamma(:,1)';
      s{1}.col = Gamma(:,2)';
  else
      s = {};
  end

  [p,q] = dmperm(G.X);
  Gamma = [Gamma;... 
          [G.row(p)' G.col(q)']];
  dm = GetDMParts(G.X);

  for i = 1:length(dm.M0)
      s{end+1}.row = G.row(dm.M0{i}.row);
      s{end}.col = G.col(dm.M0{i}.col);
  end
end

function [E,found] = admissibleEdges(G)
  % init
  E = [0 0];
  found = 0;

  % G = G^+
  dm = GetDMParts(G.X);
  n = length(dm.M0);
  i = 1;
  while ~found && i<=n 
      [r,c] = find(G.X(dm.M0{i}.row,dm.M0{i}.col)==2);
      if ~isempty(r)
          E = [G.row(dm.M0{i}.row(r(1)))...
              G.col(dm.M0{i}.col(c(1)))];
          found = 1;
      end
      i = i+1;
  end
end
