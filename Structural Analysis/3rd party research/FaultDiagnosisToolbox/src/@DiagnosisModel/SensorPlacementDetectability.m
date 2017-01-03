function [res,idx] = SensorPlacementDetectability( model, fdet )
% SensorPlacementDetectability  Determine minimal set of sensors to achieve detectability
%
%    [res,idx] = model.SensorPlacementDetectability( [fdet] )
%
%  Computes all minimal sensor sets that achieves detectability of the
%  faults in the model. It is possible, with the fdet argument, aim for a
%  subset of the faults.
%
%    Krysander, Mattias, and Erik Frisk, "Sensor placement for fault 
%    diagnosis." Systems, Man and Cybernetics, Part A: Systems and Humans, 
%    IEEE Transactions on 38.6 (2008): 1398-1410.
%
%  Inputs:
%    fdet(optional) - Specify which faalts to be detected, defaults to all
%                     faults in the model. Specify ith indices into model.f
%                     or with cell array of fault name strings.
%
%  Outputs:
%    res      - cell array of all minimal sensor sets, represented with
%               strings
%    idx      - same as res, but represented with indicices into model.f

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)
  
  if nargin < 2
    fdet = 1:numel(model.f);
  elseif isa(fdet,'cell')
    [~,fdet] = ismember(fdet,model.f);
  end
  
  % Check that model has no underdetermined part
  dm = GetDMParts(model.X);  
  if ~isempty(dm.Mm.row)
    error('Sorry, sensor placement algorithm only works for models with no underdetermined part');
  end
  
  % Determine the set of non-detectable faults  
  feq = zeros(1,numel(fdet));
  for ii=1:numel(feq)
    feq(ii) = find(model.F(:,fdet(ii)));
  end
  
  nondet = find(ismember(feq,dm.M0eqs));
  res = {};
  idx = {};
  if numel(nondet)>0
    detectabilitySets = DetectabilitySets( model.X, model.F(:,fdet(nondet)), model.P );
    idx = model.mhs( detectabilitySets );
    res = cell(1,numel(idx));
    for ii=1:numel(idx)
      idx{ii} = sort(idx{ii});
      res{ii} = model.x(idx{ii});
    end    
  end
end
