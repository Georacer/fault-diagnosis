function [res,blocksvisited,faultinlb]=LinkedM0Blocks(dm,S,k,feqblock)
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

blocksvisited = [k];
res.currblock = k;
res.currfaultidx = [];
res.lowerfaultidx = [];
faultinlb = [];

%%% Check if any faults in current block
[fq,fidx] = ismember(k,feqblock);
if fq
  res.currfaultidx = [fidx];
  faultinlb = [fidx];
end

%%% Determine set of connecting variables
connvar = S(dm.M0{k}.row,:);
if length(dm.M0{k}.row)>1
  connvar = sum(connvar)>0;
end
connvar = setdiff(find(connvar==1), dm.M0{k}.col);
if isempty(connvar)
  connvar = [];
end

res.children = {};
if ~isempty(connvar) 
  %%% Determine set of connected blocks
  connblocks=[];
  for j=1:length(dm.M0)
    if ~isempty(intersect(connvar,dm.M0{j}.col))
      connblocks = [connblocks j];
    end
  end
  % Recursive call to LinkedM0Blocks to obtain full structure of
  % connected blocks and their respectively fault structure
  for j=1:length(connblocks)
    [newchild,childvisit,flb] = LinkedM0Blocks(dm,S,connblocks(j), ...
                                               feqblock);
    blocksvisited = union(blocksvisited,childvisit);
    faultinlb = union(faultinlb,flb);
    res.children{end+1} = newchild;
    res.lowerfaultidx = union(res.lowerfaultidx,...
                              [newchild.currfaultidx, ...
                        newchild.lowerfaultidx]);
  end
end
