%% Sensor placement for isolability of detectable faults
function detSets = IsolabilitySets( X, F, P, Ispec )
  detSets = {};
  
  nf = size(F,2);
  for ii=1:nf
    isolDetSets = IsolabilitySubProblem(X, F, P, ii, Ispec(ii,:));
    detSets = [detSets isolDetSets{:}];
  end
end

function detSets=IsolabilitySubProblem( X, F, P, f, Ispec )
  % Isolate from f
  ef = find(F(:,f));
  
  n = size(X,1);
  nf = size(F,2);
  
  % Misol = M\{ef}
  Xisol = X([1:ef-1,ef+1:n],:);
  Fisol = F([1:ef-1,ef+1:n],:);
  
  % Extract just determined part of Xisol
  dm = GetDMParts(Xisol);
  X0 = Xisol(dm.M0eqs, dm.M0vars);

  % Find out which faults are included in X0
  feq = zeros(1,nf);
  for ii=1:nf
    e = find(Fisol(:,ii));
    if isempty(e)
      e=0;
    end
    feq(ii) = e;
  end  
  nondet = ismember(feq,dm.M0eqs);
  % Adapt to isolability specification
  nondetisol = nondet & (Ispec==0);
  F0 = Fisol(dm.M0eqs,nondetisol);
  
  % Translate P to P0  
  [r,c] = ismember(P,dm.M0vars);
  P0 = c(r);

  % Compute detectability sets
  detSets = DetectabilitySets( X0, F0, P0 );
  
  % Translate back to original variable indices
  for ii=1:numel(detSets)
    detSets{ii} = dm.M0vars(detSets{ii});
  end
end