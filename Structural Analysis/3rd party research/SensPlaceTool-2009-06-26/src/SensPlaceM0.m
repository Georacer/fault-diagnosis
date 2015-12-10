function res=SensPlaceM0(S,feq,svar)
% Internal function, no help text written

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01

% Copyright (C) 2006 Erik Frisk and Mattias Krysander
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
  svar = [1:size(S,2)];
end

dm = GetDMParts(S);

if ~(isempty(dm.Mm.row) && isempty(dm.Mp.row))
  error('Structure is not exactly determined');
end

%%% Compute which blocks the faults influence
feqblock = [];
blocklist = (1:length(dm.M0));
for k=1:length(feq)
  for l=1:length(blocklist)
    if ismember(feq(k),dm.M0{l}.row)
      feqblock(k)=l;
    end
  end
end

lb = {};
while ~isempty(blocklist)
  cb = blocklist(1); % Current block
  % Compute linked block structure
  [lb{end+1},connectedblocks,flb] = LinkedM0Blocks(dm,S,cb,feqblock); 
  % Remove processed blocks from blocklist
  blocklist = sort(setdiff(blocklist,connectedblocks));
end

% Compute block and fault order from the lb structure
nf = length(feqblock);
nb = length(dm.M0);
fom = eye(nf);
bom = eye(nb);
for k=1:length(lb)
  [fom,bom] = FaultAndBlockOrder(lb{k},fom,bom); 
end

maxfaultsdetectable = false;

while ~maxfaultsdetectable
  maxfaultsdetectable = true;
  res = {};
  mf = find(sum(fom)==1); % Extract highest order faults

% For each maximal fault, compute higher ranked blocks, i.e.
% blocks we need to measure from
  hrblocks = {};
  for k=1:length(mf)
    hrblocks{k} = find(bom(:,feqblock(mf(k)))==1)';
  end
% Translate blocks into variables, variable res
% represents a conjunction of disjunctions
  for k=1:length(mf)
    cols = [];
    for l=1:length(hrblocks{k})
      cols = [cols dm.M0{hrblocks{k}(l)}.col];
    end
    cols = intersect(cols, svar);
    if isempty(cols) % fault class k is not possible to make
                     % detectable wiith the specified possible sensor positions. 
                     % Remove fault from fault order fom and restart
                     % Not the most efficient implementation, room for improvement.
      maxfaultsdetectable=false;
      fom(k,:) = zeros(1,length(feq));
      fom(:,k) = zeros(length(feq),1);      
    end
    res{end+1} = cols;
  end
end
