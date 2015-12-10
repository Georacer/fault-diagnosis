function S = FindMSO(sm,p)

% FindMSO  Performs structural analysis to obtain all MSOs and optionally
% also all PSOs.
%
%    S = FindMSO(sm,p)
%
%  Inputs:
%      - sm   A structural model of the unnknown variables represented with
%             its biadjacency matrix.
%
%      - p    If p is true all PSO sets are also stored in the output
%             S.PSOs. The default value is false.
%
%  Outputs:
%    S.MSOs      - The family of all MSO sets in sm. 
%
%    S.PSOs      - The family of all PSO sets in sm.
%
%  Example:
%    >> sm = [1 0;1 0;1 1;0 1;0 1];
%    >> p = false;
%    >> S = FindMSO(sm,p)
%
%    S = 
%
%        MSOs: {[4 5]  [3 2 5]  [3 2 4]  [1 3 5]  [1 3 4]  [1 2]}
%
% Author:   Mattias Krysander Revision: 0.1,  
% Date: 2008/01/16 Copyright (C) 2008 Mattias Krysander
%
% FindMSO is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 2 of the License, or (at your option)
% any later version.
%
% FindMSO is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
% more details.
%
% You should have received a copy of the GNU General Public License along
% with FindMSO; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
global withPSO
if nargin<2
    withPSO = 0;
else
    withPSO = p;
end

[row_over,col_over]=Mp(sm); %Computes the overdetermined part.
sr = length(row_over)-length(col_over);
S.MSOs = {};
if withPSO
        S.PSOs = {};
end
if sr > 0
    sm = sm(row_over,col_over);
    for i=1:length(row_over)
        M{i} = row_over(i);
    end
    delM = 1;
    no_classes = length(M);
    S.MSOs = {};
    
    S = sub(sm,M,sr,delM,no_classes);
end


function S = sub(sm,M,sr,delM,no_classes)
% A subroutine to FindMSO
global withPSO

if withPSO 
    S.PSOs = {[M{:}]};
end
if sr==1
    S.MSOs = {[M{:}]};
else
    S.MSOs = {};
    Mesleft = no_classes - delM + 1;

    if withPSO 
        psi = Mesleft-1;
    else
        psi = Mesleft - sr + 1;
    end
    
    while psi >= 0
        idxM = [1:delM-1 delM+1:no_classes];
        [row_just,row_over,col_over]=GetJustOver(sm(idxM,:));

        merge = length(row_just)>0;

        if merge
            no_rows_before = sum(row_just < delM);
            Mesleft = Mesleft - (length(row_just) - no_rows_before);

            if withPSO | sr-1<=Mesleft
                mergeclasses = [idxM(row_just) delM];
                delM = delM - no_rows_before;
                sm =[sm(idxM(row_over(1:delM-1)),col_over);...
                    any(sm(mergeclasses,col_over));...
                    sm(idxM(row_over(delM:end)),col_over)];
                M = [M(idxM(row_over(1:delM-1))) {[M{mergeclasses}]}...
                    M(idxM(row_over(delM:end)))];
                no_classes = no_classes - length(row_just);
                if no_rows_before==0
                    idxM = [1:delM-1 delM+1:no_classes];
                    Sn=sub(sm(idxM,:),M(idxM),sr-1,delM,no_classes-1);
                    S.MSOs=[S.MSOs Sn.MSOs];
                    if withPSO 
                        S.PSOs =[S.PSOs Sn.PSOs];
                    end
                end
                delM=delM+1;
                Mesleft = no_classes - delM + 1;
                if withPSO 
                    psi = Mesleft-1;
                else
                    psi = Mesleft - sr + 1;
                end
            else
                break;
            end
        else
            Sn=sub(sm(idxM,:),M(idxM),sr-1,delM,no_classes-1);
            S.MSOs=[S.MSOs Sn.MSOs];
            if withPSO 
                S.PSOs =[S.PSOs Sn.PSOs];
            end
            delM=delM+1;
            Mesleft = no_classes - delM + 1;
            if withPSO 
                psi = Mesleft-1;
            else
                psi = Mesleft - sr + 1;
            end
        end
    end
end



function [row_just,row_over,col_over]=GetJustOver(sm)
%   Computes the just and over determined part of a structural
%              matrix. 
%
%    [row_just,row_over,col_over]=GetJustOver(sm)
%
%  Inputs:
%    sm  - A biadjacency matrix with a non-empty structurally
%                 overdetermined part and an empty structurally underdetermined part. 
%
%  Output:
%    row_just   - The row indices of the just-determind part.
%    row_over   - The row indices of the overdetermined part. 
%    col_over   - The column indices of the overdetermined part.
if ~size(sm,2)
    col_over = [];
    row_just = [];
    row_over = 1:size(sm,1);
else
    [p,q,r,s]=dmperm(sm);

    %last component
    rtmp=[r(end-1):r(end)-1];
    k=[s(end-1):s(end)-1];
    row_over = sort(p(rtmp)); % behövs detta
    col_over = q(k);

    %all but the last component
    r=[1:r(end-1)-1];
    row_just = p(r);
end



function [row_over,col_over]=Mp(sm)
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
if ~size(sm,2)
    col_over = [];
    row_over = 1:size(sm,1);
else
    [p,q,r,s]=dmperm(sm);
    rtmp=[r(end-1):r(end)-1];
    k=[s(end-1):s(end)-1];
    if length(rtmp) > length(k) % if overdetermined part exist
        row_over = sort(p(rtmp)); % behövs detta
        col_over = q(k);
    else
        row_over = [];
        col_over = [];
    end
end

