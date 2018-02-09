function [df,ndf] = DetectabilityAnalysis( model, varargin )
% DetectabilityAnalysis  Performs a structural detectability analysis
% 
%   [df,ndf] = model.DetectabilityAnalysis(options)
%
%  Options are key/value pairs
%
%  Key          Value
%    causality  Can be 'mixed' (default), 'int', or 'der' for mixed,
%               integral, or derivative causality analysis respectively.
%               See 
%
%                 Frisk, E., Bregon, A., Aaslund, J., Krysander, M., 
%                 Pulido, B., Biswas, G., "Diagnosability analysis
%                 considering causal interpretations for differential
%                 constraints", IEEE Transactions on Systems, Man and 
%                 Cybernetics, Part A: Systems and Humans, 2012, 42(5), 
%                 1216-1229.  
% Outputs: 
%   df      Detectable faults
%   ndf     Non-detectable faults

% Copyright Erik Frisk, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  p = inputParser;
  p.addOptional('causality','mixed');
  p.parse(varargin{:});
  opts = p.Results;
    
  if strcmp(opts.causality,'mixed')
    Mplusfun=@computeMixed;
  elseif strcmp(opts.causality,'der')
    Mplusfun=@computeDeriv;
  elseif strcmp(opts.causality,'int')
    Mplusfun=@computeInteg;
  else
    error('Incorrect causality specification');
  end

  Xp = Mplusfun(model.X);
  mp = Xp.row;
  [feq,~]  = find(model.F>0);  
  det = ismember(feq,mp);
  
  df  = model.f(det);
  ndf = model.f(det==0);
end
