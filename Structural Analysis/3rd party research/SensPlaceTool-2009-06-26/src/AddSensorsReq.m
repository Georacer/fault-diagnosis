function [res,freqnew]=AddSensorsReq(SM,sens,freq,fadd)
% Internal function, no help text written

% Author(s): Erik Frisk, Mattias Krysander
% Revision: 0.1, Date: 2006/12/01
%           0.2, Date: 2007/09/01
%           0.21, Date: 2009/03/18

% Copyright (C) 2006,2009 Erik Frisk and Mattias Krysander
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

% Only add constraint, no sensor variable
% lumped structure assumed
% sens = {'variable name k'}
% fadd \subseteq SM.x or a logical value.
% fadd = 0 => fadd = the empty set
% fadd = 1 => fadd = sens.
% all sensor faults is required to be isolable
%
% No sensor-variable is added!

if nargin<4
  fadd = {}; % no additional sensors introduce new faults.
  elseif isnumeric(fadd)||islogical(fadd)
    if fadd == 0
      fadd = {};  % no additional sensors introduce new faults
    else
      fadd = sens;% all additional sensors introduce new faults
    end
elseif ~iscell(fadd)
  error('fadd must be a logical value or a fadd \subseteq sens')
end

freqnew = freq;
res = SM;
[membq, senspos] = ismember(sens,SM.x);
ne = length(SM.e);

if ~all(membq)
  error('Trying to add sensor for a variable not in model');
end
  
tffadd = ismember(sens,fadd); 
ntffadd = sum(tffadd); % Number of new faults
nsens = length(sens);
Xa = zeros(nsens,length(SM.x));

%Fa = zeros(nsens,length(SM.f)+length(tffadd));
Fa = zeros(nsens,length(SM.f)+ntffadd);
Za = zeros(nsens,length(SM.z)+nsens);
  
for k=1:nsens
  fnum = sum(ismember(sens(1:k-1),{sens{k}}));
  % Add to X
  Xa(k,senspos(k))=1;
  
  % Add to F
  if tffadd(k)
    fsymb = sprintf('fy-%s',SM.x{senspos(k)});
    if fnum>0
      fsymb = [fsymb sprintf('%c','a'+fnum)];
    end
    res.f{end+1} = fsymb;
    Fa(k,length(res.f)) = 1;

    freqnew{end+1} = {fsymb};
  end
  
  % Add to Z
  ysymb = sprintf('y-%s',SM.x{senspos(k)});
  if fnum>0
    ysymb = [ysymb sprintf('%c','a'+fnum)];
  end  
  res.z{end+1} = ysymb;
  Za(k,length(res.z)) = 1;

  esymb = sprintf('ey-%s',SM.x{senspos(k)});
  if fnum>0
    esymb = [esymb sprintf('%c','a'+fnum)];
  end  
  res.e{end+1} = esymb;
end
res.X = [res.X;Xa];
%res.F = [res.F zeros(ne,length(tffadd));Fa];
res.F = [res.F zeros(ne,ntffadd);Fa];
res.Z = [res.Z zeros(ne,nsens);Za];
