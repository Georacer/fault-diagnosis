function S = FindMTES(m,p)
% Author(s): Mattias Krysander, Erik Frisk
% Revision: 0.1, Date: 2010/08/19
%
% Copyright (C) 2010 Mattias Krysander and Erik Frisk

% This file is part of TestModTool.
% 
% TestModTool is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% TestModTool is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%   
% You should have received a copy of the GNU General Public License along
% with TestModTool; if not, write to the Free Software Foundation, Inc., 51
% Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

% Input: a structural model m with redundancy at least 1 and with at least
% one equ.class including faults.

% Cases:
% a) The sm has structural redundancy 1. No more removals are possible.
%    Store the equations and faults.
% b) The sm has redundancy more than 1.
%    i)  There are only one equ.class including faults. No more removals are
%        possilbe. Store the equations and the faults.
%    ii) There are more than one equ.class including faults. Store the PSO
%        if all PSOs are wanted. Remove allowed classes and make a
%        reqursive call.

% Check if m is an MTES
m = LumpExt(m,1);
if length(m.f)==1 % if m is MTES
    S = storeFS(m); % then store m
else %otherwise make recursive call
    if p == 1
        S = storeFS(m);
    else
        S = initS;
    end
    row = m.delrow;
    while length(m.f)>=row % some rows are allowed to be removed
        [m,row] = LumpExt(m,row); % lump model w.r.t. row
    end
    for delrow = m.delrow:length(m.f)
        % create the model where delrow has been removed
        m.delrow = delrow;
        rows = [1:delrow-1 delrow+1:size(m.sm,1)];
        n = GetPartialModel(m,rows);
        
        Sn = FindMTES(n,p); % make recursive call
        S = addResults(S,Sn); % store results
    end   
end

