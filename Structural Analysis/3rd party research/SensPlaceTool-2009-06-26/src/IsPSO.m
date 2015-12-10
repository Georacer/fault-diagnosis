function x=IsPSO(SM);
% IsPSO  Checks if a structure represents a PSO set of equations.
%
%    res = IsPSO(S)
%
%  Inputs:
%    S     - A 0/1-matrix representing the model structure
%
%  Output:
%    res   - 1 if S is a PSO, 0 otherwise.

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

dm = GetDMParts(SM);

if isempty(dm.Mm.row) && isempty(dm.M0)
  x = 1;
else
  x = 0;
end 
