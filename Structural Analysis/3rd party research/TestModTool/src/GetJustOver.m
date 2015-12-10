function [row_just,row_over,col_over]=GetJustOver(sm)
%   Computes the just and over determined part of a structural
%              matrix. 
%
%    [row_just,row_over,col_over]=GetJustOver(sm)
%
%  Inputs:
%    sm  - A biadjacency matrix with a non-empty structurally
%          overdetermined part and an empty structurally underdetermined
%          part. 
%
%  Output:
%    row_just   - The row indices of the just-determind part.
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
    row_just = [];
    row_over = 1:size(sm,1);
else
    [p,q,r,s]=dmperm(sm);

    %last component
    rtmp=[r(end-1):r(end)-1];
    k=[s(end-1):s(end)-1];
    if length(rtmp)~=length(k)
        row_over = sort(p(rtmp));
        col_over = q(k);
        %all but the last component
        r=[1:r(end-1)-1];
        row_just = p(r);
    else
        row_over = [];
        col_over = [];
        row_just = [1:size(sm,1)];
    end
end