function Result = ObjectIsType(Data,Type,ErrorMessage)
%  Checks wether the Data is of the specified type. May optionaly issue error message if not.
%
% Receives:
%   Data                    -   struct          -   Structure initially created with ObjectCreate function. 
%   Type                    -   string          -   The name of the Data object type. Case sensitive.
%   ErrorMessage -   string           - (optional) The error message to issue if the type does not match. Default: [], no error is issued
%
% See Also:
%   CreateObject, ObjectGetType
%
%
% Example:
%   
%   
%   

error(nargchk(2,3,nargin));
error(nargoutchk(0,1,nargout));

if ~ischar(Type) 
    error('Type must be string')
end
ObjectType = ObjectGetType(Data);
Result = strcmp(ObjectType,Type);

if ~Result & exist('ErrorMessage','var') & ~isempty(ErrorMessage) & ischar(ErrorMessage)
    error(ErrorMessage)
end