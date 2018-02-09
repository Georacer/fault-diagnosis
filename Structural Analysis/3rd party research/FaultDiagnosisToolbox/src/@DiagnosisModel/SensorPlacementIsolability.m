function [s, sIdx] = SensorPlacementIsolability( model, varargin )
% SensorPlacementIsolability  Determine minimal set of sensors to achieve maximal fault isolability
%
%    [res,idx] = model.SensorPlacementIsolability(options)
%
%  Computes all minimal sensor sets that achieves maximal fault isolability
%  of the faults in the model. 
%
%    Krysander, Mattias, and Erik Frisk, "Sensor placement for fault 
%    diagnosis." Systems, Man and Cybernetics, Part A: Systems and Humans, 
%    IEEE Transactions on 38.6 (2008): 1398-1410.
%
%  Options are key/value pairs
%
%  Key                         Value
%    isolabilityspecification  Isolability specification, a 0/1-matrix with
%                              a 0 in position (i,j) if fault fi should be
%                              isolable from fault fj; 1 otherwise. Structural
%                              isolability is a symmetric relation; and if
%                              the specification is not symmetric; the
%                              specification is made symmetric. Defaults to
%                              the identity matrix, i.e., full isolability
%                              among faults.
%
%   isolatenewfaults           Should new faults also be isolated (default:
%                              true)
%
%  Outputs:
%    res      - cell array of all minimal sensor sets, represented with
%               strings
%    idx      - same as res, but represented with indicices into model.f

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  n = numel(model.f);

  p = inputParser;
  p.addOptional('isolabilityspecification',eye(n));
  p.addOptional('isolatenewfaults', true);
  p.parse(varargin{:});
  opts = p.Results;
    
  Ispec = opts.isolabilityspecification;
  if ~all(all(Ispec-Ispec'==0))
    warning('Isolability specification need to be symmetric, making it so...');
    Ispec = (Ispec + Ispec')>0;
  end
  
  s = {};
  sIdx = {};
  nx = size(model.X,2);
  nf = size(model.F,2);
  
  dm = GetDMParts(model.X);
  if ~isempty(dm.Mm.row)
    error('Sorry, sensor placement algorithm only works for models with no underdetermined part');
  end
  
  % Determine sensor sets to make non-detectable faults detectable
  [~, sIdxDet] = SensorPlacementDetectability( model );

  if numel(sIdxDet) > 0
    for ii=1:numel(sIdxDet)
      % Create the extended model
      [Xs,Fs,fs] = SensorEqs( sIdxDet{ii}, nx, nf, model.Pfault );
      Xe = [model.X;Xs];            
      if opts.isolatenewfaults
        Fe = [model.F zeros(size(model.F,1),numel(fs));Fs];
        Fe = Fe(:,any(Fe,1));
        Ispecii = [Ispec zeros(size(Ispec,1),numel(fs));...
          zeros(numel(fs),size(Ispec,2)), eye(numel(fs))];
      else
        Fe = [model.F;zeros(size(Xs,1),size(model.F,2))];
        Ispecii = Ispec;
      end
      
      % Compute sensor sets for the isolation problem
      D = IsolabilitySets(Xe, Fe, model.P, Ispecii);
      SiIdx = model.mhs( D );

      % Add sets to solution
      for jj=1:numel(SiIdx)
        SiIdx{jj} = sort([SiIdx{jj} sIdxDet{ii}]);
      end
      sIdx = [sIdx SiIdx{:}];
    end
  else
    D = IsolabilitySets(model.X, model.F, model.P, Ispec);
    sIdx = model.mhs( D );    
  end
  
  % Remove duplicates
  keepIdx = ones(1,numel(sIdx));
  for kk=1:numel(sIdx)
    for ll=kk+1:numel(sIdx)
      if (numel(sIdx{kk})==numel(sIdx{ll})) && all(sIdx{kk}==sIdx{ll})
        keepIdx(ll)=0;
      end
    end
  end
  sIdx = sIdx(keepIdx>0);
  
  % Translate to variable names
  s = cell(1,numel(sIdx));
  for ii=1:numel(sIdx)
    s{ii} = model.x(sIdx{ii});
  end    
end


function [Xs, Fs, fs] = SensorEqs( s, nx, nf, Pfault )
  ns = numel(s);
  
  Xs = zeros(ns,nx);
  Fs = zeros(ns,nf);
  fs = [];
  for ii=1:ns
    Xs(ii,s(ii)) = 1;
    if ismember( s(ii), Pfault )
      fs(end+1) = s(ii);
      Fs(:,end+1) = zeros(ns,1);
      Fs(ii,end)  = 1;
    end
  end
end

