function senssets = SensPlaceIsolSM(SM,svar,fadd,freq)
% SensPlaceIsolSM  Performs sensor placement analysis to obtain 
%                  isolability.
%
%    senssets = SensPlaceIsolSM(SM,svar,fadd,freq)
%
%  Inputs:
%    SM     - A structural model object
%    svar   - Cell-array of possible sensor locations
%    fadd   - Variable indicating if the newly added sensor can also 
%             become faulty, i.e. if faults corresponding to the newly added
%             sensors should be included in the model.
%  
%             There are three cases:
%             fadd=0: No new faults for the added sensors
%             fadd=1: New faults for all added sensors
%             fadd = set of variable names: Sensors measuring
%             variables in fadd can become faulty, the others can 
%             not become faulty.
%   freq    - (optional argument) Isolability specification. If
%             specification is not given, maximum isolability is specified.
%             Example, three faults f1, f2, and f3 in the model and we require
%             isolability between f1 and the other two faults but not necessarily 
%             between f2 and f3. Then:
%               freq = {{'f1'}, {'f2','f3'}}
%
%  Output:
%   senssets - Set of all minimal sensor sets obtaining the specification (if possible), 
%              i.e. all minimal hitting sets on the family of sets in D.
%
%   See also: CreateSM, IsolabilityAnalysisSM, SensPlaceDetSM
%

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1,  Date: 2006/12/01
%           0.11, Date: 2007/07/11, Bugfix!
%           0.2,  Date: 2007/09/01

% Copyright (C) 2006,2007 Erik Frisk and Mattias Krysander
%
% This file is part of SensPlaceTool.
% 
% SensPlaceTool is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% SensPlaceTool is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%   
% You should have received a copy of the GNU General Public License
% along with SensPlaceTool; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

if nargin < 3
  fadd=0;
end

if nargin < 4
  freq = {};
  for i=1:length(SM.f)
    freq{i} = {SM.f{i}};
  end
end

fdet = [freq{:}];
sensdet = MinimalSPSets(SensPlaceDetSM(SM,svar,fdet));

senssets = {};
for i = 1:length(sensdet)
  [SMd,freqnew] = AddSensorsReq(SM,sensdet{i},freq,fadd); 
  sensisol = MinimalSPSets(SensPlaceInDetectableSM(SMd,svar,freqnew));
  for k=1:length(sensisol)  
    senssets{end+1}=multisetunion(sensdet{i},sensisol{k});
  end
end

senssets = SimplifySP(senssets);

