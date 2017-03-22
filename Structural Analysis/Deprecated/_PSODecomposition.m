function res = PSODecomposition(gh, X)
% PSODecomposition  Decomposes a PSO structure into equivalence classes
%
%    res = PSODecomposition(S)
%
%  Inputs:
%    X     - A 0/1-matrix representing the model structure
%
%  Output:
%    res   - A structure representing the PSO decomposition
%
%        res.eqclass
%          A cell array of equivalence classes. Each element in the
%          cell array is a structure with row and column indices.
%
%        res.trivclass
%          List of the trivial classes, row indexes.
%
%        res.X0
%          List of indexes to X0 variables
%
%        res.p, res.q
%          Complete list of row and column indexes to obtain
%          the canonical decomposition
%
%   For more details on the canonical decomposition, see Chapter 4 in
%   "Design and Analysis of Diagnosis Systems Using Structural Methods"
%   PhD thesis, Mattias Krysander, link�pings universitet, 2006.
%   http://www.fs.isy.liu.se/Publications/

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

dm = gh.getDMParts(X);

if ~(isempty(dm.Mm.row) && isempty(dm.M0))
    error('Decomposition only for PSO structures')
end

[n,m] = size(X);
delrows = [1:n];

eqclass = {};
trivclass = [];
Mi = [];

while length(delrows)>0
    temprow = setdiff([1:n],delrows(1));
    
    dm = gh.getDMParts(X(temprow,:));
    
    if ~isempty(dm.M0vars)
        foo.row = sort([delrows(1) temprow(dm.M0eqs)]);
        foo.col = dm.M0vars;
        eqclass{end+1} = foo;
        Mi = [Mi foo.col];
        delrows = setdiff(delrows, foo.row);
    else
        trivclass(end+1) = delrows(1);
        delrows = delrows(2:end);
    end
end

X0 = sort(setdiff(1:m,Mi));
if isempty(X0)
    X0=[];
end
res.eqclass = eqclass;
res.trivclass = trivclass;
res.X0 = X0;

res.p = [];
res.q = [];
for k=1:length(eqclass)
    res.p = [res.p eqclass{k}.row];
    res.q = [res.q eqclass{k}.col];
end
res.p = [res.p trivclass];
res.q = [res.q X0];
