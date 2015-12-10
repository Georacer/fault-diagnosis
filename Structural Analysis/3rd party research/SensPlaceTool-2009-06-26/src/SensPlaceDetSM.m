function res = SensPlaceDetSM(SM,svar,fdet)
% SensPlaceDetSM  Performs sensor placement analysis to obtain 
%                 detectability.
%
%    res = SensPlaceDetSM(SM,svar,fdet)
%
%  Inputs:
%    SM     - A structural model object
%    svar   - Cell-array of possible sensor locations
%    fdet   - Cell-array of faults to be detected
%
%  Output:
%    res    - Sets of detectability sets, i.e.
%             a sensor set that obtains maximum detectability 
%             of faults in fdet has non-empty intersection with all 
%             sets in res. 
%
%   See also: CreateSM, IsolabilityAnalysisSM, SensPlaceIsolSM

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01
%           0.2, Date: 2007/09/01

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

[tf,loc]=ismember(fdet,SM.f);

% Extract the M0-part
dm = GetDMParts(SM.X);

SM0.X = SM.X(dm.M0eqs,dm.M0vars);
SM0.x = SM.x(dm.M0vars);
SM0.f = SM.f;
SM0.F = SM.F(dm.M0eqs,:);
if nargin == 3
    SM0.F = SM0.F(:,loc);
end

% Determine number of non-detectable faults  
res = {};
numfaults = sum(any(SM0.F));
if numfaults> 0  
    feqr = find(any(SM0.F,2)==1); % Determine rows with faults
    [tf,svarloc]=ismember(svar,SM0.x);
    
    m0sens  = SensPlaceM0(SM0.X,feqr,svarloc);

    %% Translate sensor indices into variable names
    for m=1:length(m0sens)
      res{end+1} = SM0.x(m0sens{m});
    end
    res=SimplifySP(res);
end
