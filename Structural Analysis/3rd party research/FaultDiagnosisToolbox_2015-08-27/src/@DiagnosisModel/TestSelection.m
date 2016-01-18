function r=TestSelection( model, arr, varargin )
% TESTSELECTION - A minimal hitting set based test selection.
%
%   Find sets of tests, based on a set of equations or a fault sensitivity 
%   matrix, FSM, that achieves isolability performance specifications
% 
%      model.TestSelectionFSM( arr, options );
%
%   Simple test selection strategy that finds sets of tests that, ideally, 
%   fulfills specified isolability performance specifications. Note that
%   this is a purely structural method, no noise or model uncertainty
%   considerations are used.
%  
%  Input:
%    arr                 If arr is a matrix, this is interpreted as a fault
%                        sensitivity matrix. If it is a cell array of
%                        vectors, it is interpreted as a set of equations
%                        sets used to design residuals.
%
%
%  Options can be given as a number of key/value pairs
%
%  Key                   Value
%    isolabilitymatrix   Matrix specifying required isolability
%                        performance. A 0 in position (i,j) represents that
%                        fault i is isolable from fault j, a 1 indicates
%                        that fault i is not isolable from fault j. A fault
%                        can not be isolable from itself and hterefore must
%                        the diagonal always be 1.
%
%    method              Choice of test seleciton method. 
%                          'full' - Finds all subset minimal sets of tests
%                                   that fulfills requirements. Warning,
%                                   might easily lead to computationally
%                                   intractable problems. Consider using
%                                   the the aminc method or the compiled minimal 
%                                   hittingset implementation (see class method
%                                   CompiledMHS) (default)
%
%                        'aminc' -  Same approach as full, but uses the
%                                   aminc approximative minimal cardinality 
%                                   hitting set approach from:
%                                     Cormen, L., Leiserson, C. E., and
%                                     Ronald, L. (1990). Rivest, 
%                                     "Introduction to Algorithms.", 1990. 
%
%                                   Information also in De Kleer, Johan. "Hitting set 
%                                   algorithms for model-based diagnosis." 
%                                   22th International Workshop on Principles 
%                                   of Diagnosis, DX, 2011.
%
%  Outputs:
%    r - Sets of possible sets of tests that achieve diagnosability 
%        requirements
%
%  Example:
%    model.TestSelectionFSM( FSM );
%
%      or to specify a target isolability matrix with aminc method
%
%    model.TestSelectionFSM( FSM, 'isolabilitymatrix', targetIM, 'method', 'aminc' );

% Removed this option, aminc is a better choice
%                        'greedy' - A greedy search for 1 set of tests that
%                                   fulfills performace specifications.
%                                   Fast with good complexity properties,
%                                   but can not guarantee to find the
%                                   smallest set of tests.
%             

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)


  pa = inputParser;
  pa.addOptional( 'isolabilitymatrix', [] );
  pa.addOptional( 'method', 'full');
  pa.parse(varargin{:});
  opts = pa.Results;

  if isa(arr,'cell')
    FSM = model.FSM(arr);
  else
    FSM = arr;
  end
  
  imMax = model.IsolabilityAnalysisFSM(FSM);
  if isempty(opts.isolabilitymatrix)
    im = imMax;
  else
    im = opts.isolabilitymatrix;
  end
  
  if any(any((im-imMax)<0))
    warning('Isolability specification infeasible, aiming for maximal isolability');
    im = imMax;
  end
  
  if strcmp(opts.method,'full')  
    r = model.mhs(TestSets(FSM,im));
  elseif strcmp(opts.method,'greedy')  
    r = Greedy(FSM,im);
  elseif strcmp(opts.method,'aminc')  
    r = sort(aminc(TestSets(FSM,im),size(FSM,1)));
  else
    error('Specified method: %s not supported',opts.method);
  end  
end

function hs=aminc(pi,n)
  piM = zeros(length(pi),n);
  for k=1:length(pi)
    piM(k,pi{k})=1;  
  end
  hs = [];
  while nnz(piM)>0
    [~,tIdx] = max(sum(piM,1));
    hs(end+1) = tIdx;
    piM(piM(:,tIdx)==1,:)=0;
  end
end

function ts = TestSets(FSM,im)
  [r,c] = find(im==0);
  ts = cell(1,length(r));
  for ii=1:length(r)
    ts{ii} = find((FSM(:,r(ii))==1) & (FSM(:,c(ii))==0))';
  end
end

function selTests = Greedy( FSM, imtarget )
  nf = size(FSM,2);
  
  selTests = [];
  candidateTests = 1:size(FSM,1);
  im = ones(nf,nf);
  
  while norm(im-imtarget)>0
    ut = zeros(1,length(candidateTests));
    
    for k=1:length(ut)
      det = FSM(candidateTests(k),:)==1;
      isol = FSM(candidateTests(k),:)==0;
      im2 = im; im2(det,isol)=0;
      ut(k) = sum(sum(im-im2));
    end
    [~,gt] = max(ut);
    det = FSM(candidateTests(gt),:)==1;
    isol = FSM(candidateTests(gt),:)==0;
    im(det,isol)=0;
    selTests(end+1) = candidateTests(gt);
    candidateTests = setdiff(candidateTests,candidateTests(gt));
  end  
  selTests = sort(selTests);
end
