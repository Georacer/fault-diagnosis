function [row_over,col_over,sr]=Mp(sm)
%   Computes the overdetermined part of a structural
%              matrix. 
%
%    [row_over,col_over]=Mp(sm)
%
%  Inputs:
%    sm  - A biadjacency matrix. 
%
%  Output:
%    row_over   - The row indices of the overdetermined part. 
%    col_over   - The column indices of the overdetermined part.

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
if ~size(sm,2)
    col_over = [];
    row_over = 1:size(sm,1);
else
    [p,q,r,s]=dmperm(sm);
    rtmp=[r(end-1):r(end)-1];
    k=[s(end-1):s(end)-1];
    if length(rtmp) > length(k) % if overdetermined part exist
        row_over = p(rtmp); % behövs detta
        col_over = q(k);
    else
        row_over = [];
        col_over = [];
    end
end
sr = length(row_over)-length(col_over);


