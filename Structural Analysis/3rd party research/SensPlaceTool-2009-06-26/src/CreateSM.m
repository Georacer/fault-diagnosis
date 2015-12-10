function SM=CreateSM(X, F, Z, relnames, xnames, fnames, znames)
% CreateSM  Create a structural model object from incidence matrices
%
%   SM = CreateSM(X,F,Z,relnames, xnames, fnames, znames)
%
%  Inputs:
%    X     - A 0/1-matrix representing the model structure of the unknown variables
%    F     - A 0/1-matrix representing the model structure of the fault variables
%    Z     - A 0/1-matrix representing the model structure of the known variables
%    relnames, xnames, fnames, znames (optional)
%          - cell-arrays of strings with names of equations, unknown variables, 
%            fault variables, known variables. An empty array {} gives default names.
%  Output:
%    SM   - A structural model object.
%
  
% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1,  Date: 2006/12/01
%           0.11, Date: 2007/03/21
%           0.2   Date: 2007/09/01

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

  if nargin < 7
    znames = {};  
  end
  if nargin < 6
    fnames = {};  
  end
  if nargin < 5
    xnames = {};  
  end
  if nargin < 4
    relnames = {};  
  end
  if nargin < 3
    Z = [];
  end
  
  
  [nx,mx] = size(X);
  [nf,mf] = size(F);
  [nz,mz] = size(Z);
 
  ne = max([nx nf nz]);
  
  SM.name = 'Sample model';
  
  if any(sum(F)>1)
    error(['Reformulate model such that fault variables only appear ' ...
           'in 1 equation only']);
  end
  
  if isempty(xnames)
    SM.x = {};
    for k=1:mx
      SM.x{k} = strcat('x',num2str(k));
    end
  else
    SM.x = xnames;
  end
  
  if isempty(fnames)
    SM.f = {};
    for k=1:mf
      SM.f{k} = strcat('f',num2str(k));
    end
  else
    SM.f = fnames;
  end

  if isempty(znames)
    SM.z = {};
    for k=1:mz
      SM.z{k} = strcat('z',num2str(k));
    end
  else
    SM.z = znames;
  end

  if isempty(relnames)
    SM.e = {};
    for k=1:ne
      SM.e{k} = strcat('e',num2str(k));
    end
  else
    SM.e = relnames;
  end  

  SM.X = X;
  SM.F = F;
  SM.Z = Z;
 