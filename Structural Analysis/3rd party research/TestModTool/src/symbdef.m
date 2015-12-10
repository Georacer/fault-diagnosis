function M=symbdef(equ_symb, symbols)
% Internal function, no help text written

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01

% Copyright (C) 2006 Erik Frisk and Mattias Krysander
%
% This file is part of TestModTool.
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

M = zeros(length(equ_symb), length(symbols));

for eq=1:size(M,1)  
  for k=1:length(equ_symb{eq})
    if iscell(equ_symb{eq}{k})
      idx = find(strcmp(equ_symb{eq}{k}{1},symbols)~=0);
    else
      idx = find(strcmp(equ_symb{eq}{k},symbols)~=0);
    end
    if length(idx)>1
      error('Bzzt...');
    elseif length(idx)==1
      if iscell(equ_symb{eq}{k})
	M(eq,idx) = equ_symb{eq}{k}{2};
      else
        M(eq,idx) = 2; 
      end
    end
  end
end

