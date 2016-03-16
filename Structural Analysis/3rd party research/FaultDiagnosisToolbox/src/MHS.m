function [mhs,ti] = MHS( conflist, cutoff )
  if nargin < 2
    cutoff=-1;
  end
  ncomps = max([conflist{:}]);
  nconf = length(conflist);
  confmat = zeros(nconf,ncomps);
  for k=1:nconf
    c = conflist{k};
    for l=1:length(c)
      confmat(k,c(l))=1;
    end
  end
  trs = sparse(confmat);
  tic;
  n = size(trs,2);
  mmhs = logical(sparse([],[],[],1,n));
  for k=1:size(trs,1)
	  mmhs = SPMHS(trs(k,:),mmhs,n, cutoff);
  end
  ti=toc*1000;
  
  mhs = cell(1,size(mmhs,1));
  for l=1:size(mmhs,1)
    mhs{l}=find(mmhs(l,:));
  end  
end

function d = SPMHS(tr,d,n, cutoff)
  dnew = logical(sparse([],[],[],0,n));
  dold = d;
  k=0;
  while size(dold,1)>k
    k = k+1;
    if ~any(and(dold(k,:),tr))
      tmp = dold(k,:);
      idx = find(tr);
      dold=dold([1:k-1, k+1:end],:);
      k = k-1;
      if cutoff<0 || sum(tmp)<cutoff
        for l=1:length(idx)
          cand = tmp;
          cand(idx(l)) = 1;
          candmin = 1;
          j=1;
          while candmin && j<=size(dold,1)           
            if all(and(dold(j,:),cand)==dold(j,:))
                candmin=0;
            end
            j=j+1;
          end
          if candmin
            dnew(end+1,:) = cand;
          end
        end
      end
    end
  end
  d = [dold;dnew];
end
