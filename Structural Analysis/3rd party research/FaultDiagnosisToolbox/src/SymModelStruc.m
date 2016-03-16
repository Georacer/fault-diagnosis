function [X,x] = SymModelStruc( rels, x)
  ne = length( rels );
  nx = length( x );
  X = zeros(ne, nx);
  
  for k=1:length(rels)
    if isa(rels{k},'sym')
      xIdx = eq2struc(rels{k}, x);
      X(k,xIdx) = 1;  
    elseif isdiffconstraint( rels{k} )
      [rd,cd] = ismember(char(rels{k}{1}),x); % char() perhaps not needed
      [ri,ci] = ismember(char(rels{k}{2}),x);
      X(k,cd(rd)) = 3;
      X(k,ci(ri)) = 2;      
    elseif isifconstraint( rels{k} )
      cxIdx = eq2struc(rels{k}{1}, x);
      e1xIdx = eq2struc(rels{k}{2}, x);
      e2xIdx = eq2struc(rels{k}{3}, x);
      X(k,[cxIdx e1xIdx, e2xIdx]) = 1;  
    else
      error('Unknown constraint type');
    end
  end
  xIdx = any(X,1);
  X = X(:,xIdx);
  x = x(xIdx>0);
end

function xIdx = eq2struc( eq, x)
  sVar = symvar( eq );
  xIdx = [];
  for k=1:length(sVar)
    [xMember,xi]=ismember(char(sVar(k)),x);
    if xMember
      xIdx(end+1) = xi;
    end
  end
end

function r=isdiffconstraint( eq )
  r = (iscell(eq) && length(eq)==3 && ...
    strcmp(eq{3},'diff'));
end

function r=isifconstraint( eq )
  r = (iscell(eq) && length(eq)==4 && ...
    strcmp(eq{4},'if'));
end

