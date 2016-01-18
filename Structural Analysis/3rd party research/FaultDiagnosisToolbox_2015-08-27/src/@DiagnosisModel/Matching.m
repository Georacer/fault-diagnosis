function Gamma=Matching(model,eq)  
% Matching  Compute a matching in the model for a set of equations
%
%    Gamma = model.Matching( eq )  
%  
%  Outputs:
%    eq       - Set of equations (indices)
%
%  Outputs:
%    Gamma    - Structure representing the obtained matching

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  dm = GetDMParts(model.X(eq,:));

  % Check for well formed problem
  if length(dm.M0eqs) ~= length(eq)
    error('Matching only computed for exactly determined models');
  end

  n = length(dm.M0);
  Gamma.matching = cell(1,n);
  
  intCausal = false;
  derCausal = false;
  
  % Iterate over all Hall components
  for h=1:n;
    eqi = eq(dm.M0{h}.row);
    vi  = dm.M0{h}.col;
    
    intEdge = any(any(model.X(eqi,vi)==2));
    derEdge = any(any(model.X(eqi,vi)==3));
    if ~intEdge && ~derEdge
      Gamma.matching{n-h+1}.type = 'Algebraic';
      Gamma.matching{n-h+1}.row  = eqi;
      Gamma.matching{n-h+1}.col  = vi;
    elseif length(eqi)==1 && derEdge
      Gamma.matching{n-h+1}.type = 'Der';
      derCausal = true;
      Gamma.matching{n-h+1}.row = eqi;
      Gamma.matching{n-h+1}.col = vi;
    elseif length(eqi)==1 && intEdge
      Gamma.matching{n-h+1}.type = 'Int';
      intCausal = true;
      Gamma.matching{n-h+1}.row = eqi;
      Gamma.matching{n-h+1}.col = vi;
    else
      % Loop with differential constraints, i.e., no derivative causality
      % possible
      intCausal = true;

      % Try to find integral causality solution
      % This only works for low-index problems, 
      % TODO: use more general solution from paper
      Gammai = MatchIntegralCausality(model.X(eqi,vi));
      if ~isempty(Gammai)
        Gammai.row = eqi;
        Gammai.col = vi;

        Gamma.matching{n-h+1} = Gammai;
        Gamma.matching{n-h+1}.type = 'Int';
      else
      % If that fails, find mixed causality matching
        warning('Mixed causality matching for single Hall component not yet implemented');
        % Gammai = mixedCausalMatching(model.X(eqi,vi));
        Gamma.matching{n-h+1}.row = []; %eqi(Gammai.row);
        Gamma.matching{n-h+1}.col = []; %vi(Gammai.col);
      end      
    end
  end
  
  if ~derCausal && ~intCausal
    Gamma.type = 'Algebraic';
  elseif derCausal && ~intCausal
    Gamma.type = 'Der';
  elseif ~derCausal && intCausal
    Gamma.type = 'Int';
  else  
    Gamma.type = 'Mixed';
  end
end

function Gammai = MatchIntegralCausality(X0)
  
  n = size(X0,1);
  
  % Identify all integral variables and constraints
  iVar = find(any(X0==2,1));
  iEq  = find(any(X0(:,iVar)==2,2))';
  restVar = setdiff(1:n,iVar);
  restEq  = setdiff(1:n,iEq);
  
  if sprank( X0(restEq,restVar) ) == n-length(iVar)
    dm = GetDMParts( X0(restEq,restVar) );
    
    Gammai.hod = cell(1,length(dm.M0)); % hod = highest order derivatives
    n0 = length(dm.M0);
    for k=1:n0
      Gammai.hod{k}.row = restEq(dm.M0{n0-k+1}.row);
      Gammai.hod{k}.col = restVar(dm.M0{n0-k+1}.col);
    end
    Gammai.int.row = iEq;
    Gammai.int.col = iVar;
  else
    % Could not find an integral causality matching
    Gammai = [];
  end
end
