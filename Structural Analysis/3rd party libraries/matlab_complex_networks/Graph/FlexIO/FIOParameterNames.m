function ParamterNames = FIOParameterNames(InputCells)
% THe function test if the input is of legal format.
%
% Receives:
%   InputCells      -   cell array  -   The function input extracted from varargin.
%
% Returns:
%   ParamterNames   -   boolean     -   True (1) if the input looks valid, False (0) if not.
%   ErrorString -   string      -   (optional) The error description or an empty string.
%   
% Created:
% Lev Muchnik    26/03/2002, 
% +972-54-4326496, LevMuchnik@gmail.com

error(nargchk(1,1,nargin));
error(nargchk(0,1,nargout));

[Success ParamterNames] = FIOTestInput(ParamterNames);

if Success 
   ParamterNames = InputCells{1:2:end};
else
    ParamterNames = {};
end