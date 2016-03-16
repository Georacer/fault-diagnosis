function detSets = DetectabilitySets( X, F, P )
  dm = GetDMParts(X);  
  
  detSets = SensPlaceM0(X(dm.M0eqs, dm.M0vars),F(dm.M0eqs,:));
  for jj=1:numel(detSets)
    detSets{jj} = intersect(dm.M0vars(detSets{jj}),P);
  end
end

%% Sensor placement in exactly determined system
function res=SensPlaceM0(X,F)
  dm0 = GetDMParts( X );
  bfOrder = BlockAndFaultOrder( X, F, dm0 );

  res = {};
  for jj=1:numel(bfOrder.bFm)
    d = D(bfOrder.blockOrder, bfOrder.bFm(jj), dm0);
    if ~isempty(d)
      res{jj} = d;
    end
  end
end

%% Compute block partial order and blocks corresponding
%  to maximal fault classes
function res = BlockAndFaultOrder( X, F, dm0 )
  n = length(dm0.M0);

  % 1. Construct block adjacency matrix
  % Xb(i,j) = 1 => bi > bj

  % 1.1 Determine directly connected blocks
  Xb = zeros(n);
  for rr=1:n
    for cc=1:n
      Xb(rr,cc) = any(any(X(dm0.M0{rr}.row,dm0.M0{cc}.col),1),2);
    end
  end

  % 1.2 Traverse block adjacency matrix to determine indirect relationships
  for bb=2:n
    ba = find(Xb(1:bb-1,bb)>0); %% Get directly adjacent blocks
    iba = []; % Indirectly adjacent blocks
    for ll=1:length(ba)
      iba = [iba;ParentBlocks(Xb,ba(ll))];
    end
    Xb(unique(iba),bb) = 1;
  end  

  % 2. Construct fault classes and determine maximal elements 

  % 2.1 Determine e_f for each fault (must be 1 equation for each fault) 
  ef = zeros(1,size(F,2));
  for jj=1:numel(ef)
    ef(jj) = find(F(:,jj)>0,1);
  end

  % 2.2 Determine block membership for each fault
  efrep = unique(ef);

  efb = zeros(1,numel(efrep));
  for k=1:numel(efrep)
    for l=1:n
      if ismember(efrep(k),dm0.M0{l}.row)
        efb(k)=l;
      end
    end      
  end

  % 2.3 Determine blocks corresponding to maximal elements in the
  %     fault class partial order
  maxFaultClasses = zeros(1,numel(efb));
  for jj=1:numel(maxFaultClasses)
    maxFaultClasses(jj) = isempty(intersect(ParentBlocks(Xb,efb(jj)),...
                                            efb));
  end    
  bFm = efb(maxFaultClasses>0);

  % 3. Collect the results
  res.blockOrder = Xb;
  res.bFm        = bFm;
end

%% Compute detectability sets for a given block order Xb, fault block fb
%  and Dulmage-Mendelsohn decomposition of initial model
function v=D(Xb,fb,dm)
  v = [];
  pb = [ParentBlocks(Xb,fb);fb];
  for jj=1:numel(pb);
    v = union(v,dm.M0{pb(jj)}.col);
  end    
end

%% Compute parent blocks bi>b (strict inequality)
function bp = ParentBlocks(X,b)
  bp = find(X(1:b-1,b));
end

