function [im,ndf,df]=IsolabilityAnalysisSM(SM)  
% IsolabilityAnalysisSM -  Perform isolability analysis of a structural model
%
%     [im,ndf,df]=IsolabilityAnalysisSM(SM)  
%
%  Inputs:
%    SM     - A structural model in the SM format
%
%  Output:
%    im     - Matrix representation of isolability analysis
%    ndf    - cell array of non-detectable faults
%    df     - cell array with detectable faults. Faults that
%             can not be isolated from each other are put in the
%             same cell array object.
%
%  See also: CreateSM, SensPlaceDetSM, SensPlaceIsolSM
  
% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01
%           0.2, Date: 2007/09/01 

% Copyright (C) 2006, 2007 Erik Frisk and Mattias Krysander
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

% No derived equations/variables
% fault only in 1 equation
  
nx = length(SM.x);
nf = length(SM.f);
nz = length(SM.z);
dm = GetDMParts(SM.X);
  
% Create SM object for the PSO-part
SMp.X = SM.X(dm.Mp.row,dm.Mp.col);
SMp.F = SM.F(dm.Mp.row,:);
SMp.Z = SM.Z(dm.Mp.row,:);
SMp.e = SM.e(dm.Mp.row);
SMp.x = SM.x(dm.Mp.col);
SMp.f = SM.f;
SMp.z = SM.z;

npx = length(SMp.x);
npf = length(SMp.f);
npz = length(SMp.z);

% Extract fault equation numbers
feq = zeros(1,nf);
for k=1:nf
  feq(k) = find(SM.F(:,k)==1);
end

% Determine non-detectable faults
ndrows = dm.Mm.row;
for k=1:length(dm.M0)
  ndrows = [ndrows dm.M0{k}.row];   
end
ndf = SM.f(ismember(feq,ndrows)==1);

if ~isempty(SMp.e) 
  %% Uses PSO equivalence classes to determine isolability blocks
  %% Compute equivalence class decomposition of PSO
  psod = PSODecomposition(SMp.X);
    
  %% Extract fault equation numbers in PSO
  psofeq = [];
  for k=1:length(SMp.f)
    if any(SMp.F(:,k))
      psofeq(k) = find(SMp.F(:,k)==1);
    else
      psofeq(k) = -1;
    end
  end
  feqclass = {};
  for k=1:length(psod.eqclass)
    foo = SMp.f(find(ismember(psofeq,psod.eqclass{k}.row)==1));
    if length(foo)>1
      feqclass{end+1} = foo;
    elseif length(foo)==1
      feqclass(end+1) = foo;
    end
  end
  for k=1:length(psod.trivclass)
    foo = SMp.f(find(ismember(psofeq,psod.trivclass(k))==1));      
    if length(foo)>1
      feqclass{end+1} = foo;
    elseif length(foo)==1
      feqclass(end+1) = foo;
    end
  end
else
  feqclass = {};
end
  
numfaults = length(SM.f);
im = eye(numfaults);

if ~isempty(ndf)
  [foo,bar] = ismember(ndf,SM.f);
  im(bar,:) = ones(length(bar),numfaults);
end
finclass = {};
for k=1:length(feqclass)
  finclass = union(finclass,feqclass{k});
  [foo,bar] = ismember(feqclass{k},SM.f);
  im(bar,bar) = ones(length(bar),length(bar));
end
df = feqclass;
foo = setdiff(SM.f, union(ndf,finclass));
for k=1:length(foo)
  df(end+1) = foo(k);
end
  