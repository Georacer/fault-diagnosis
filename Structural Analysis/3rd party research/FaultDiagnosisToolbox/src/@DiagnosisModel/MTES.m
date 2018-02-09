function mtes = MTES( model )
% MTES  Computes the set of minimal test equation support
%
%    mtes = model.MTES()  
%
%  "A Structural Algorithm for Finding Testable Sub-models and 
%  Multiple Fault Isolability Analysis", Mattias Krysander, Jan Aaslund, 
%  and Erik Frisk, 2010, 21st International Workshop on Principles of 
%  Diagnosis (DX-10). Portland, Oregon, USA.
%  
%  Outputs:
%    mtes     - Cell array with all MTES sets

% Copyright Erik Frisk, Mattias Krysander, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
   
  fidx=zeros(1,size(model.X,1));
  for k=1:length(fidx)
    fk = find(model.F(k,:)>0,1,'first'); %% Hack!
    if ~isempty(fk)
      fidx(k)=fk;
    end
  end
  mtes = TESsub(model.X,fidx,0);
  mtes = mtes.eq;
end

function S = TESsub(sm,f,p)
  S.eq = {};
  S.f = {};
  S.sr = [];

  m = initModel(sm,f); % overdetermined or empty
  if m.sr>0 && ~isempty(m.f)
         S = FindMTES(m,p);
  end
end

function m = initModel(sm,f)
  dm = GetDMParts(sm);

  row_over = dm.Mp.row;
  col_over = dm.Mp.col;
  m.sr = length(row_over)-length(col_over);
  
  f = f(row_over);
  idxf = find(f); 
  idx = [idxf setdiff(1:length(row_over),idxf)];
  f = f(idx);
  row_over = row_over(idx);

  m.sm = sm(row_over,col_over);
  m.f = {};
  for i=1:length(idxf)
    m.f{i} = f(i);
  end
  m.e = {};
  for i=1:length(row_over)
    m.e{i} = row_over(i);
  end
  m.delrow = 1;
end

function S = FindMTES(m,p)
  m = LumpExt(m,1);
  if length(m.f)==1 % if m is MTES
    S = storeFS(m); % then store m
  else %otherwise make recursive call
    if p == 1
      S = storeFS(m);
    else
      S.eq = {};
      S.f = {};
      S.sr = [];
    end
    row = m.delrow;
    while length(m.f)>=row % some rows are allowed to be removed
      [m,row] = LumpExt(m,row); % lump model w.r.t. row
    end
    for delrow = m.delrow:length(m.f)
      % create the model where delrow has been removed
      m.delrow = delrow;
      rows = [1:delrow-1 delrow+1:size(m.sm,1)];
      n = GetPartialModel(m,rows);

      Sn = FindMTES(n,p); % make recursive call
      S = addResults(S,Sn); % store results
    end   
  end
end

function [n,row] = LumpExt(m,row)
  no_rows = size(m.sm,1);
  remRows = [1:row-1 row+1:no_rows];
  remRowsf = [1:row-1 row+1:length(m.f)];
  
  dm = GetDMParts(m.sm(remRows,:));
  row_just = dm.M0eqs;
  row_over = dm.Mp.row;
  col_over = dm.Mp.col;
  
  if ~isempty(row_just)
    eqcls = [remRows(row_just) row];
    no_rows_before_row = sum(eqcls < row);
    row = row - no_rows_before_row;
    no_rows_before = sum(eqcls < m.delrow);
    n.delrow = m.delrow - no_rows_before;

    eqclsf = eqcls(eqcls<=length(m.f));
    row_overf = row_over(row_over<=length(remRowsf));

    if no_rows_before > 0 
      rowinsert = n.delrow;
    else
      rowinsert = row;
    end
    n.sm = [m.sm(remRows(row_over(1:rowinsert-1)),col_over);...
        any(m.sm(eqcls,col_over));...
        m.sm(remRows(row_over(rowinsert:end)),col_over)];

    n.e = [m.e(remRows(row_over(1:rowinsert-1))) {[m.e{eqcls}]}...
        m.e(remRows(row_over(rowinsert:end)))];
      
    n.f = [m.f(remRowsf(row_overf(1:rowinsert-1))) {[m.f{eqclsf}]}...
        m.f(remRowsf(row_overf(rowinsert:end)))];

    n.sr = m.sr;

    if no_rows_before > 0 
        n.delrow = n.delrow+1;
    end
  else
    n = m;
  end
  row = row + 1;
end

function S = storeFS(m)
  S.eq = {sort([m.e{:}])};
  S.f = {sort([m.f{:}])};
  S.sr = m.sr;
end

function n = GetPartialModel(m,rows)
  n.sm = m.sm(rows,any(m.sm(rows,:),1));
  n.e =  m.e(rows);
  n.f = m.f(intersect(rows,1:length(m.f)));
  n.sr = size(n.sm,1)-size(n.sm,2);
  n.delrow = length(find(rows<m.delrow))+1;
end

function S = addResults(S,Sn)
  S.eq = [S.eq Sn.eq];
  S.f = [S.f Sn.f];
  S.sr = [S.sr Sn.sr];
end
