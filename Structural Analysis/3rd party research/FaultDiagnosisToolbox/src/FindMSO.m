function [msos,psos] = FindMSO(X,p)

% FindMSO  Performs structural analysis to obtain all MSOs and optionally
% also all PSOs.
%
%    [msos,psos] = FindMSO(sm,p)
%
%  Inputs:
%      - X    A structural biadjacency matrix.
%
%      - p    If p is true all PSO sets are also computed
%
%  Outputs:
%    msos      - The family of all MSO sets in sm. 
%
%    psos      - The family of all PSO sets in sm.
%
%  Example:
%    >> X = [1 0;1 0;1 1;0 1;0 1];
%    >> p = false;
%    >> S = FindMSO(X,p)
%
%    S = 
%
%        {[4 5]  [3 2 5]  [3 2 4]  [1 3 5]  [1 3 4]  [1 2]}
%
  if nargin<2
    withPSO = 0;
  else
    withPSO = p;
  end
  
  dm = GetDMParts(X);
  row_over = dm.Mp.row;
  col_over = dm.Mp.col;
  
  sr = length(row_over)-length(col_over);
  msos = {};
  if withPSO
    psos = {};
  end
  if sr > 0
    X = X(row_over,col_over);
    M = cell(1,numel(row_over));
    for i=1:numel(row_over)
      M{i} = row_over(i);
    end
    delM = 1;
    no_classes = length(M);
    S = sub(X,M,sr,delM,no_classes,withPSO);
    msos = S.MSOs;
    if withPSO
      psos = S.PSOs;
    end  
  end
end

function S = sub(sm,M,sr,delM,no_classes,withPSO)
  if withPSO 
    S.PSOs = {[M{:}]};
  end
  if sr==1
    S.MSOs = {[M{:}]};
  else
    S.MSOs = {};
    Mesleft = no_classes - delM + 1;

    if withPSO 
        psi = Mesleft-1;
    else
        psi = Mesleft - sr + 1;
    end
    
    while psi >= 0
      idxM = [1:delM-1 delM+1:no_classes];
      dm = GetDMParts(sm(idxM,:));
      row_just = dm.M0eqs;
      row_over = dm.Mp.row;
      col_over = dm.Mp.col;

      merge = ~isempty(row_just);

      if merge
        no_rows_before = sum(row_just < delM);
        Mesleft = Mesleft - (length(row_just) - no_rows_before);

        if withPSO || sr-1<=Mesleft
          mergeclasses = [idxM(row_just) delM];
          delM = delM - no_rows_before;
          sm =[sm(idxM(row_over(1:delM-1)),col_over);...
              any(sm(mergeclasses,col_over));...
              sm(idxM(row_over(delM:end)),col_over)];
          M = [M(idxM(row_over(1:delM-1))) {[M{mergeclasses}]}...
              M(idxM(row_over(delM:end)))];
          no_classes = no_classes - length(row_just);
          if no_rows_before==0
            idxM = [1:delM-1 delM+1:no_classes];
            Sn=sub(sm(idxM,:),M(idxM),sr-1,delM,no_classes-1, withPSO);
            S.MSOs=[S.MSOs Sn.MSOs];
            if withPSO 
              S.PSOs =[S.PSOs Sn.PSOs];
            end
          end
          delM=delM+1;
          Mesleft = no_classes - delM + 1;
          if withPSO 
            psi = Mesleft-1;
          else
            psi = Mesleft - sr + 1;
          end
        else
          break;
        end
      else
        Sn=sub(sm(idxM,:),M(idxM),sr-1,delM,no_classes-1, withPSO);
        S.MSOs=[S.MSOs Sn.MSOs];
        if withPSO 
          S.PSOs =[S.PSOs Sn.PSOs];
        end
        delM=delM+1;
        Mesleft = no_classes - delM + 1;
        if withPSO 
          psi = Mesleft-1;
        else
          psi = Mesleft - sr + 1;
        end
      end
    end
  end
end
