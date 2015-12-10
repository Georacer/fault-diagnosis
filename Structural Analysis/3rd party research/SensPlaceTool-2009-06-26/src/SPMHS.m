function newmsp=SPMHS(sensset,msp)
% SPMHS  Computes minimal hitting sets
%
%    newmsp = SPMHS(sensset,msp)
%
%  Inputs:
%    sensset - New set
%    msp     - Current set of minimal hitting sets
%
%  Outputs:
%    newmsp  - Updated set of minimal hitting sets
  
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

  newmsp = {};
  candadd = {};
  mspold = msp;
  k=0;
  while length(mspold)>k
      k = k+1;
  %for k=1:length(msp)
    if isempty(intersect(mspold{k},sensset))
      tmp = mspold{k};  
      mspold=mspold([1:k-1, k+1:end]); 
      k = k-1;
      for l=1:length(sensset)
        newcand = union(tmp, sensset(l)); 
        candmin = 1;
        j=1;
        while candmin & j<=length(mspold)
          [tf,loc] = ismember(mspold{j},newcand);          
          if all(tf)
            candmin=0;
          end
          j=j+1;
        end
        if candmin
          candadd{end+1} = newcand;
        end
      end
    end
  end
  
  newmsp = {mspold{:},candadd{:}};
  