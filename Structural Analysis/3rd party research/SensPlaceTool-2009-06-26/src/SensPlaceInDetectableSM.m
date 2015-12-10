function res=SensPlaceInDetectableSM(SM,svar,freq)
% SensPlaceInDetectableSM  Place sensors for full isolability in a 
%                          structural model where all faults are detectable
%
%    res=SensPlaceInDetectableSM(SM,svar,freq)
%
%  Inputs:
%    SM     - A structural model object
%    svar   - List of possible sensor locations
%    freq   - Isolability requirement specification
%
%  Output:
%    res    - Representation of possible sensor locations and res 
%             is a set of sets. A set of sensors that fulfills the 
%             isolability requirement must have a non-empty 
%             intersection with each set in res

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1,  Date: 2006/12/01
%           0.11, Date: 2007/07/11 - Bugfix + handle freq correctly
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

if nargin < 3 || isempty(freq)
  freq = cell(1,length(SM.f));
  for k=1:length(SM.f)
    freq{k} = SM.f(k);
  end
end

freqloc = {};
res = {};
for i=1:length(freq)
   [tf,freqloc{i}] = ismember(freq{i},SM.f);
end

fdettot = [];
for i=1:length(freqloc)
    fdettot = [fdettot freqloc{i}];
end

% determine equation number for each fault
nx = length(SM.x);
nz = length(SM.z);
nf = length(SM.f);

feq = zeros(1,nf); 
for k=1:nf
    feq(k) = find(SM.F(:,k)==1); 
end

%for each class except the last
for cl = 1:length(freqloc)-1
    fsens = {};
    fdet = setdiff(fdettot,freqloc{cl});
    %for each fault in cl
    for idxfj = 1:length(freqloc{cl})
      %decouple fault
        fj = freqloc{cl}(idxfj);
        SMd = SMRemoveEq(SM,feq(fj));
        % required isolability
        sens = SensPlaceDetSM(SMd,svar,SM.f(fdet));
        fsens = {fsens{:} sens{:}};
    end
    %eqrsens represents a conjuction of disjunctions
    res = {res{:} fsens{:}};
end
res = SimplifySP(res);
