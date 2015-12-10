function [S] = PSO(SM)
% PSO -  finds all Proper Structurally Overdetemined (PSO) equations sets
% in a structural model.
%
%     [S] = PSO(SM)
%
%  Inputs:
%    SM     - A structural model in the SM format
%
%  Outputs:
%    S.MSOs - cell array of MSO represented as index sets.
%    S.PSOs - cell array of PSO represented as index sets.
%
%  See also: CreateSM, MTES, TES, MSO
  
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

fidx=zeros(1,size(SM.X,1));
for k=1:length(fidx)
  fk = find(SM.F(k,:)>0);
  if ~isempty(fk)
    fidx(k)=fk;
  end
end
S = FindMSO(SM.X,1);