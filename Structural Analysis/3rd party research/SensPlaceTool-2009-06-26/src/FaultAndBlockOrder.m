function [fomnew,bomnew]=FaultAndBlockOrder(lb,fom,bom)
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

fomnew = fom;
bomnew = bom;

chldblocks = [];
for k=1:length(lb.children)
  chldblocks(end+1) = lb.children{k}.currblock;
end
bomnew(lb.currblock,chldblocks) = 1;

if ~isempty(lb.currfaultidx)
  fomnew(lb.currfaultidx,lb.lowerfaultidx) = 1;
end

for k=1:length(lb.children)
  [fomnew,bomnew] = FaultAndBlockOrder(lb.children{k},fomnew,bomnew);
  bomnew(lb.currblock,:) = or(bomnew(lb.currblock,:),...
                              bomnew(lb.children{k}.currblock,:));
end
