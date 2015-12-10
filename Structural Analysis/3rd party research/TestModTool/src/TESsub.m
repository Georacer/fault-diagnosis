function S = TESsub(sm,f,p)
% FindTES -  finds either all Minimal Test Equation Sets and Minimal Test
% Sets in a structural model or all Test Equation Sets and Test Sets in a
% structural model
%
%     S = TESsub(sm,f,p)
%
%  Inputs:
%    sm     - 0/1-matrix representing the structure of the unknown signals.
%    f      - row vector, where f(i) = j means that fault j is included in 
%             the equation corresponding to the i:te row in sm. f(i) = 0
%             means that no fault is included in equation i. It is assumed
%             the each fault only enters in one equation.
%    p      - logical variable, where P = 0 means only minimal TES and TS
%             should be included in the output S.   
%   
%
%  Output:
%    S.eq   - cell array of TES or MTES represented as index sets. 
%    S.f    - cell array of TS or MTS represented as index sets.
%    S.sr   - vector with the structural redundancy of each TES or MTES.
%
%  See also: TES, MTES
  
% Author(s): Mattias Krysander, Erik Frisk
% Revision: 0.1, Date: 2010/08/19

% Copyright (C) 2010 Mattias Krysander and Erik Frisk
%
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


S = initS;
m = initModel(sm,f); % overdetermined or empty
if m.sr>0 & ~isempty(m.f)
       S = FindMTES(m,p);
end
