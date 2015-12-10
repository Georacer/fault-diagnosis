function res=SMRemoveEq(SM,k)
% SMRemoveEq  Removes an equation in a structural model
%
%    res=SMRemoveEq(SM,k)
%
%  Inputs:
%    SM     - A structural model object
%    k      - An integer specifying which equation to remove
%
%  Output:
%    res   - A new structural model object

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

res.name = SM.name;
res.x = SM.x;
res.z = SM.z;
res.f = SM.f;
res.e = SM.e([1:k-1 k+1:end]);
res.X = SM.X([1:k-1 k+1:end],:);
if size(SM.Z,2)>0
  res.Z = SM.Z([1:k-1 k+1:end],:);
else
  res.Z = [];
end
res.F = SM.F([1:k-1 k+1:end],:);
  
  
  