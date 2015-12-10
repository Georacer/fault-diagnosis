function simpsp=SimplifySP(sp)
% SimplifySP  Simplify a sensor placement representation
%    The function accepts a set S of sets of sensor locations and 
%    removes any set from S that is a superset of another set in S
%
%   simpS=SimplifySP(S)
%  

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01
%           0.2, Date: 2007/09/01

% Copyright (C) 2006, 2007 Erik Frisk and Mattias Krysander
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

splen  = zeros(1,length(sp));
for k=1:length(sp)
  splen(k) = length(sp{k});
end
[s,sidx] = sort(splen);
simpsp = sp(sidx);
k=1;
while k<length(simpsp)
  remidx = [];
  for l=k+1:length(simpsp)
    [tf,loc] = ismember(simpsp{k},simpsp{l});
    if issubmultiset(simpsp{k},simpsp{l})
      remidx(end+1) = l;
    end
  end
  keepidx = setdiff(1:length(simpsp),remidx);
  simpsp = simpsp(keepidx);
  k = k+1;
end

    
    