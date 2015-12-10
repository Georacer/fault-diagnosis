function [Success,varargout] = FIOTestInput(InputCells)
% THe function test if the input is of legal format.
%
% Receives:
%   InputCells  -   cell array  -   The function input extracted from varargin.
%
% Returns:
%   Success     -   boolean             -   True (1) if the input looks valid, False (0) if not.
%   ErrorString -   string,cellarray    -   (optional) The error description if the success is 0 or the InputCells variable if not.
%   
% Created:
% Lev Muchnik    26/03/2002
% +972-54-4326496, LevMuchnik@gmail.com

error(nargchk(1,1,nargin));
error(nargchk(0,2,nargout));

if iscell(InputCells) & numel(InputCells) == 1 & iscell(InputCells{1})
    InputCells = InputCells{1};
end

if ~iscell(InputCells)
    ErrorString = 'The input is not a cell array';
    Success = 0;
elseif mod(numel(InputCells),2)
    ErrorString = 'The input cell array must have an even number of elements';
    Success = 0;
else
    Success = 1;
    ErrorString = '';
    for i = 1 : 2 : numel(InputCells)
        if Success
            if ~ischar(InputCells{i}) | ~isvarname(InputCells{i})
                 Success = 0;
                 ErrorString = ['Parameter name number ' num2str(ceil(i/2)) ' does not have a valid parameter name'];
             end
        end
    end
end

if nargout > 1
    if Success
        varargout{1} = InputCells;
    else
        varargout{1} = ErrorString;
    end
end