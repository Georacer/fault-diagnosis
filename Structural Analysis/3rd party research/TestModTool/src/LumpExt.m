function [n,row] = LumpExt(m,row)

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

no_rows = size(m.sm,1);
remRows = [1:row-1 row+1:no_rows];
remRowsf = [1:row-1 row+1:length(m.f)];
[row_just,row_over,col_over]=GetJustOver(m.sm(remRows,:));
merge = length(row_just)>0;

if merge
    
    eqcls = [remRows(row_just) row];
    no_rows_before_row = sum(eqcls < row);
    row = row - no_rows_before_row;
    no_rows_before = sum(eqcls < m.delrow);
    n.delrow = m.delrow - no_rows_before;
    
    eqclsf = eqcls(eqcls<=length(m.f));
    row_overf = row_over(row_over<=length(remRowsf));
    
    if no_rows_before > 0 
        rowinsert = n.delrow;
    else
        rowinsert = row;
    end
    n.sm = [m.sm(remRows(row_over(1:rowinsert-1)),col_over);...
        any(m.sm(eqcls,col_over));...
        m.sm(remRows(row_over(rowinsert:end)),col_over)];
    
    n.e = [m.e(remRows(row_over(1:rowinsert-1))) {[m.e{eqcls}]}...
        m.e(remRows(row_over(rowinsert:end)))];
    
    n.f = [m.f(remRowsf(row_overf(1:rowinsert-1))) {[m.f{eqclsf}]}...
        m.f(remRowsf(row_overf(rowinsert:end)))];
    
    n.sr = m.sr;
    
    if no_rows_before > 0 
        n.delrow = n.delrow+1;
    end
else
    n = m;
end
row = row + 1;

