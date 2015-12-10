function Success = FIOProcessInputParameters(FunctionInput,DefaultValues)
% The function executes the cell array of parameter names and values in caller's workspace.
%
%   Receives:
%       FunctionInput     -   cell array  -   The cell array that consists of parameter names and there values. The format is:
%                                               {'Var1 Name',Var1 Value,'Var2 Name',Var2 Value,...}
%       DefaultValues     -   cell array  -   (optional) The default values, may be overriden with FunctionInput.  The format is the 
%                                             the same as for the function input.  
%
%   Returns:
%       Success           -     boolean   -     True (1) if the input was legal and applied successfuly.
%
%   
% Created:
% Lev Muchnik    26/03/2002
% +972-54-4326496, LevMuchnik@gmail.com

error(nargchk(1,2,nargin));
error(nargchk(0,1,nargout));

if ~exist('DefaultValues','var')
    DefaultValues = {};
end

try   
    Success  = 1;
    [Success DefaultValues] = FIOTestInput(DefaultValues);    
    if Success 
        [Success FunctionInput] = FIOTestInput(FunctionInput);
    end
    if Success 
        for i = 1:2:numel(DefaultValues)
            assignin('caller',DefaultValues{i},DefaultValues{i+1});
        end
        for i = 1:2:numel(FunctionInput)
            assignin('caller',FunctionInput{i},FunctionInput{i+1});
        end    
    end
catch
    Success = 0;
end

