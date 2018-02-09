function [df,ndf] = DetectabilityAnalysis( model )
% DetectabilityAnalysis  Performs a structural detectability analysis
% 
%   [df,ndf] = model.DetectabilityAnalysis()
%
% Outputs: 
%   df      Detectable faults
%   ndf     Non-detectable faults

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  dm = GetDMParts(model.X);
  mp = dm.Mp.row;
  [feq,~]  = find(model.F>0);  
  det = ismember(feq,mp);
  
  df  = model.f(det);
  ndf = model.f(det==0);
end
