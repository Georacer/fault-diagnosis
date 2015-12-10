function res=AddSensorsSM(SM,sens,fadd)
% AddSensorsSM  Adds a set of sensors to a structural model
%
%    SMnew = AddSensorsSM(SM,sens,fadd)
%
%  Inputs:
%    SM            - A structural model object
%
%    sens          - Set of sensors that should be measured.
%                    One sensor measuring x1 and two measuring x2 
%                    then becomes
%                                sens = {'x1','x2','x2'}
%
%    fadd          - Variable indicating if the newly added sensor can also 
%                    become faulty, i.e. if faults corresponding to the newly added
%                    sensors should be included in the model.
%  
%                    There are three cases:
%                    fadd=0: No new faults for the added sensors
%                    fadd=1: New faults for all added sensors
%                    fadd = set of variable names: Sensors measuring
%                    variables in fadd can become faulty, the others can 
%                    not become faulty.
%  
%  Output:
%    SMnew         - A new structural model object
%
%  See also: CreateSM, PlotSM
%
 
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
if nargin < 3
  fadd=0;
end
res= AddSensorsReq(SM,sens,{},fadd);
