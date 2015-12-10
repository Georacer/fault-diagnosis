function Type = ObjectGetType(Data)
%  Returns the type of the object
%
% Receives:
%   Data                -   struct          -   Structure initially created with ObjectCreate function. Will return it's type.
%                         anythhing else - an empty string is returned.
%
% Returns:
%   Type            -   string          -   The name of the Data object type
%
% See Also:
%   CreateObject
%
%
% Example:
%   
%   
%   
%       Input 'Data'  is allowed to be array of structs.


error(nargchk(1,1,nargin));
error(nargoutchk(0,1,nargout));

if isstruct(Data) & isfield(Data,'Type') & ischar(Data(1).Type)
    Type = Data(1).Type;
else
    Type = '';
end