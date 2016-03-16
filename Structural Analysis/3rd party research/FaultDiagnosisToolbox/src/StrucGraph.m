classdef StrucGraph < handle
  properties %(Hidden)
    vx = [];
    vf = [];
    Ex = [];
    Ef = [];
    c = {};
    cid = [];
  end
  
  methods
    function obj=StrucGraph(X, F, C, vx, vf, cid)
      if nargin<2
        X = [];
        F = [];
      end
      if nargin < 3
        C = arrayfun(@(x) {x},1:size(X,1));
      end
      if nargin < 4
        vx = 1:size(X,2);
      end
      if nargin < 5
        vf = 1:size(F,2);
      end
      if nargin < 6
        cid = 1:size(X,1);
      end
      
      obj.vx = vx;
      obj.vf = vf;
      obj.Ex = X;
      obj.Ef = F;
      obj.c  = C;
      obj.cid = cid;
    end
    
    function G2=copy(G)
      G2 = StrucGraph(G.Ex, G.Ef, G.c, G.vx, G.vf, G.cid);
    end
    
    function r=NewCid(G)
      r = max(G.cid)+1;
    end

    function f=FiCi(G, cIdx)
      if nargin < 2
        cIdx = 1:size(G.Ef,1);
      end
      f = find(any(G.Ef(cIdx,:),1));
    end
    
    function x=XiCi(G, cIdx)
      if nargin < 2
        cIdx = 1:size(G.Ex,1);
      end
      x = find(any(G.Ex(cIdx,:),1));
    end

    function G2=MinusCi( G, cIdx )
      if nargout==0
        G2=G;
      else
        G2 = StrucGraph();
      end
      keepIdx = setdiff(1:size(G.Ex,1), cIdx );
      
      G2.Ex = G.Ex( keepIdx, :);
      G2.Ef = G.Ef( keepIdx, :);
      G2.c  = G.c( keepIdx );
      G2.vx = G.vx;
      G2.vf = G.vf;
      G2.cid = G.cid( keepIdx );
    end
    
    function G2=GCi( G, cIdx )
      if nargout==0
        G2=G;
      else
        G2 = StrucGraph();
      end      
      G2.Ex = G.Ex( cIdx, :);
      G2.Ef = G.Ef( cIdx, :);
      G2.c  = G.c( cIdx );
      G2.vx = G.vx;
      G2.vf = G.vf;
      G2.cid = G.cid( cIdx );
    end
    
    function G2=MinusVx( G, xIdx )
      if nargout==0
        G2=G;
      else
        G2 = StrucGraph();
      end
      keepIdx = setdiff(1:size(G.Ex,2), xIdx );
      
      G2.Ex = G.Ex( :, keepIdx );
      G2.vx = G.vx( keepIdx );
      G2.vf = G.vf;
      G2.Ef = G.Ef;
      G2.c  = G.c;
      G2.cid = G.cid;
    end
    
    function [G2,dm]=Plus( G )
      if nargout==0
        G2=G;
      else
        G2 = StrucGraph();
      end
      dm = GetDMParts( G.Ex );
      G2.Ex = G.Ex( dm.Mp.row, dm.Mp.col );
      G2.vx = G.vx( dm.Mp.col );
      G2.vf = G.vf;
      G2.Ef = G.Ef( dm.Mp.row, :);
      G2.c  = G.c( dm.Mp.row ); 
      G2.cid = G.cid( dm.Mp.row );
    end
    
    function c = C( G, cIdx )
      if nargin < 2
        cIdx = 1:size(G.Ex,1);
      end
      
      c = [G.c{cIdx}];
    end
        
    function cIdx = CiFi( G, fIdx )
      if nargin < 2
        fIdx = 1:size(G.Ef,2);
      end
      
      cIdx = find(any(G.Ef(:,fIdx),2));
    end
    
    function r = Phi(G)
      dm = GetDMParts(G.Ex);
      r = length(dm.Mp.row) - length(dm.Mp.col);
    end
    
    function S=MTES(G)
      phiMTES = G.MinusCi(G.CiFi()).Plus().Phi()+1;
      Gplus = G.Plus();
      Ri = 1:size(Gplus.Ex,1);
      S = FindMTES(Gplus, Ri, Gplus.Phi()-phiMTES);
    end    
  end
end
  
function S = FindMTES(G, Ri, deltaPhi )
  if deltaPhi==0
    S = {sort(G.C())};
  else
    S = {};
    [Gp, Rpi] = Lump(G,G.CiFi(G.FiCi(Ri)), Ri);
    
    fiRp = Gp.FiCi(Rpi);
    while ~isempty(fiRp)
      ei = Gp.CiFi( fiRp(1) );

      Rpi = setdiff( Rpi, ei);
      S = [S{:} FindMTES(Gp.MinusCi(ei),Rpi - arrayfun(@(i) sum(ei<i),Rpi), deltaPhi-1)];
      fiRp = Gp.FiCi(Rpi);
    end
  end
end

function [Gp, Rpi] = Lump( G, C1i, Ri )
  Gp = G.copy();
  Rpi = Ri;
  
  while ~isempty(C1i)
    ci = C1i(1);
    Gr = Gp.MinusCi(ci).Plus();
    
    Ceqid = setdiff(Gp.cid,Gr.cid);
    [~,Ceqi] = ismember(Ceqid,Gp.cid); % id to index
    Vxeqi  = setdiff(Gp.vx,Gr.vx);

    [Gp,Rpi] = LumpClass(Gp, Ceqi, Vxeqi, Rpi);

    C1i = setdiff(C1i,Ceqi);
    C1i = C1i - arrayfun(@(i) sum(Ceqi<i),C1i); % HACK
  end
end

function [Gp, Rpi]=LumpClass(G, C1i, V1i, Ri)
  clump = {G.C(C1i)};
  Cnolumpi = setdiff(1:size(G.Ex,1), C1i);
  
  G1 = G.MinusVx(V1i);
  G2 = G1.GCi(C1i);
  Xlump = any(G2.Ex,1);
  Flump = any(G2.Ef,1);

  Gp = StrucGraph([G1.Ex(Cnolumpi,:);Xlump],...
                  [G1.Ef(Cnolumpi,:);Flump],... 
                  [G1.c(Cnolumpi) clump]);
  
  Rpi = setdiff(Ri,C1i);
  Rpi = Rpi - arrayfun(@(i) sum(C1i<i),Rpi); % HACK
  if all(ismember(C1i,Ri))
    Rpi(end+1) = size(Gp.Ex,1);
  end
end
  