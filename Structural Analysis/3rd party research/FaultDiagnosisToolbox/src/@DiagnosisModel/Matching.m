function Gamma=Matching(model,eq)  
  
  dm = GetDMParts(model.X(eq,:));

  % Check for well formed problem
  if length(dm.M0eqs) ~= length(eq)
    error('Sorry, matchings are currently only computed for exactly determined models');
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

    if ~intEdge && ~derEdge % Algebraic loop
      Gamma.matching{n-h+1}.type = 'algebraic';
      Gamma.matching{n-h+1}.row  = eqi;
      Gamma.matching{n-h+1}.col  = vi;
    elseif length(eqi)==1 && derEdge % Trivial D Hall component
      Gamma.matching{n-h+1}.type = 'der';
      derCausal = true;
      Gamma.matching{n-h+1}.row = eqi;
      Gamma.matching{n-h+1}.col = vi;
      %Gamma.matching{n-h+1}.derState = vi;
      Gamma.matching{n-h+1}.derState = find(model.X(eqi,:)==2);
    elseif length(eqi)==1 && intEdge % Trivial I Hall component
      Gamma.matching{n-h+1}.type = 'int';
      intCausal = true;
      Gamma.matching{n-h+1}.row = eqi;
      Gamma.matching{n-h+1}.col = vi;
      Gamma.matching{n-h+1}.intState = vi;
    else % Non-trivial Hall component with dynamic constraint(s)
      Gamma.matching{n-h+1} = MatchMixedCausality( model.X,eqi,vi );

      if strcmp(Gamma.matching{n-h+1}.type,'int')
        intCausal = true;
      end
      if strcmp(Gamma.matching{n-h+1}.type,'der')
        derCausal = true;
      end
      if strcmp(Gamma.matching{n-h+1}.type,'mixed')
        derCausal = true;
        intCausal = true;
      end      
    end
  end
  if ~derCausal && ~intCausal
    Gamma.type = 'algebraic';
  elseif derCausal && ~intCausal
    Gamma.type = 'der';
  elseif ~derCausal && intCausal
    Gamma.type = 'int';
  else  
    Gamma.type = 'mixed';
  end
end

function [Gammai, derCausal, intCausal] = MatchMixedCausality(X,eqi,vi)
  X0 = X(eqi,vi);
  gamma = mixedCausalMatching(X0);
  gamma = flipud(gamma);
  Gammai.row = eqi(gamma(:,1));
  Gammai.col = vi(gamma(:,2));
  Gammai.derState = [];
  Gammai.intState = [];
  derCausal = false;
  intCausal = false;
  for k=1:size(gamma,1)
    if X0(gamma(k,1),gamma(k,2))==2 % Integrate
      Gammai.intState(end+1) = vi(gamma(k,2));
      intCausal = true;
    elseif X0(gamma(k,1),gamma(k,2))==3 % Differentiate
      Gammai.derState(end+1) = vi(find(X0(gamma(k,1),:)==2));
      derCausal = true;
    end
  end
  if derCausal && intCausal
    Gammai.type = 'mixed';
  elseif derCausal
    Gammai.type = 'der';
  elseif intCausal
    Gammai.type = 'int';
  else
    Gammai.type = 'algebraic';
  end
end
