function dm=GetDMParts(S)
% GetDMParts  Perform Dulmage-Mendelsohn decomposition and structure the results
%
%    dm = GetDMParts(S)
%
%  Inputs:
%    S     - A 0/1-matrix representing the model structure
%
%  Output:
%    dm    - A structure representing the Dulmage-Mendelsohn decomposition.
%            The structure has the following elements:
%            Mm: structure with row/col-elements of the underdetermined part
%            Mp: structure with row/col-elements of the overdetermined part
%            M0: cell-array of the strongly connected components in the exactly
%                determined part.
%         M0eqs: list of equations in the exactly determined part
%        M0vars: list of variables in the exactly determined part
%          rowp: row permutation of S to obtain canonical form
%          colp: column permutation of S to obtain canonical form

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

[p,q,r,s] = dmperm(S);

if isempty(p) | isempty(q)
  [m,n] = size(S);
  if m>n
    dm.Mm.row = [];
    dm.Mm.col = [];
    dm.Mp.row = [1:m];
    dm.Mp.col = [1:n];    
  else
    dm.Mm.row = [1:m];
    dm.Mm.col = [1:n];
    dm.Mp.row = [];
    dm.Mp.col = [];    
  end

  dm.rowp = [1:m];
  dm.colp = [1:n];
  dm.M0 = {};
  dm.M0eqs = [];
  dm.M0vars = [];
else
  idx = 1;
  %% Existance of M-
  if s(2)>r(2)
    Mm.row = sort(p(r(1):r(2)-1));
    Mm.col = sort(q(s(1):s(2)-1));
    idx = idx+1;
  else
    Mm.row = [];
    Mm.col = [];
  end
  
  M0 = {};
  while (idx<length(r)) & (r(idx+1)-r(idx))==(s(idx+1)-s(idx)) % M0-block exists
    foo.row = sort(p(r(idx):r(idx+1)-1));
    foo.col = sort(q(s(idx):s(idx+1)-1));
    M0{end+1} = foo;
    idx = idx+1;
  end
  
  if idx<length(r) % M+ exists
    Mp.row = sort(p(r(idx):r(idx+1)-1));
    Mp.col = sort(q(s(idx):s(idx+1)-1));
  else
    Mp.row = [];
    Mp.col = [];
  end
  
  dm.Mm = Mm;
  dm.M0 = M0;
  dm.Mp = Mp;
  
  dm.M0eqs = [];
  dm.M0vars = [];
  for k=1:length(M0)
    dm.M0eqs = [dm.M0eqs M0{k}.row];
    dm.M0vars = [dm.M0vars M0{k}.col];
  end 
  dm.M0eqs = sort(dm.M0eqs);
  dm.M0vars = sort(dm.M0vars);
  
  dm.rowp = p;
  dm.colp = q;
end