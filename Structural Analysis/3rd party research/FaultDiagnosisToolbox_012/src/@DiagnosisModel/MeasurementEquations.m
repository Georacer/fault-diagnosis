function eqs = MeasurementEquations( model, yvars )
% MEASUREMENTEQUATIONS Find indices to measurement equations
%
%  eqs = model.MeasurementEquations( yvars )
%
%  yvars        Cell-array with measurement variable names. Measurement
%               variables must be subset of the known variables in the
%               model and must appear in only one place in the model. 
%               Defaults to all known variables in the model, but that is
%               probably not what you want since the known signals usually
%               also includes input signals to the model.
%

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  if nargin < 2
    yvars = model.z;
  end

  [m,yIdx] = ismember(yvars,model.z);

  if ~all(m)
    error('Measurement variables must be subset of the known variables\n');
  end
  
  eqs = zeros(1,numel(yIdx));
  for k=1:numel(yIdx)
    yEqIdx = find(model.Z(:,yIdx(k))==1);
    if length(yEqIdx)>1
      error('Measurement variable %s appears in more than one equation', yvars{k});
    end
    eqs(k) = yEqIdx;
  end
end

