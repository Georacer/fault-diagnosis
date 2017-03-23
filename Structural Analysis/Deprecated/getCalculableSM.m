function [ SM ] = getCalculableSM( SM )
%GETCALCULABLESM Provide only the just- and over-constrained part of an SM
%   blah

dm = GetDMParts(SM);

X = SM.X(dm.rowp,dm.colp);
if ~isempty(SM.F)
    F = SM.F(dm.rowp,:);
end
Z = SM.Z(dm.rowp,:);
relnames = SM.e(dm.rowp);
xnames = SM.x(dm.colp);
fnames = SM.f;
znames = SM.z;

rm = length(dm.Mm.row); cm = length(dm.Mm.col);
rj = length(dm.M0eqs); cj = rj;
rp = length(dm.Mp.row); cp = length(dm.Mp.col);

X = X(rm+1:end,cm+1:end);
relnames = relnames(rm+1:end);
xnames = xnames(cm+1:end);

SM.X = X;
SM.e = relnames;
SM.x = xnames;

end

