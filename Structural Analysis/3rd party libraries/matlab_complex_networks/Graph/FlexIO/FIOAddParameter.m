function [InputCells] = FIOAddParameter(InputCells,ParameterName,ParameterValue)
% The function adds new parameter to the input cells
%
% Receives:
%   InputCells      -   cell array  -   Cell array in FlexIO format
%   ParameterName   -   string      -   A valid parameter name.
%   ParameterValue  -   any type    -   The parameter value.
%
% Returns:
%  InputCells      -   cell array  -   Cell array in FlexIO format with the new parameter added.
%   
% Created:
% Lev Muchnik    27/03/2002, 
% +972-54-4326496, LevMuchnik@gmail.com

error(nargchk(3,3,nargin));
error(nargchk(0,1,nargout));

if iscell(InputCells) & numel(InputCells) == 1 & iscell(InputCells{1})
    InputCells = InputCells{1};
end

[Success ErrorString] = FIOTestInput(InputCells);

if ~Success
    error(['The InputCells is not given in valid FlexIO format. ' ErrorString]);
end
    
if ~ischar(ParameterName) | ~isvarname(ParameterName)
    error('The ParameterName must be a valid parameter name');
end

InputCells{end+1} = ParameterName;
InputCells{end+1} = ParameterValue;
