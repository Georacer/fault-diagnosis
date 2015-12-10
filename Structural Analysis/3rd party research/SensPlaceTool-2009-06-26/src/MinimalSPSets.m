function res=MinimalSPSets(sp)
% MinimalSPSets  Computes minimal sensor sets given a family of possible sensor locations
%
%    res=MinimalSPSets(sp)
%
%  Inputs:
%    sp     - Family of possible sensor locations
%
%  Output:
%    res    - Set of minimal sensor sets
  
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

res = {{}};
for k=1:length(sp)
  res = SPMHS(sp{k},res);
end
  