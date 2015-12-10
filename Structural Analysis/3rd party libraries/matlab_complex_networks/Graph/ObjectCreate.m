function Data = ObjectCreate(varargin)
% Creats a standatized object (structure) for data processing
%   
% Receives:
%   varargin        -   FLEX IO -   The input is in FlexIO format.  The following parameters are allowed:
%                                       Parameter Name          |  Type             |  Optional     |   Default Value |   Description
%                                          Type                 |  string           |   no          |          -                       |   The data struct type name 
%                                           Signature           |   string          |   yes         |  'CreateObject' |      Keeps list of the functions which toughed the data
%
% Returns:
%   Data           -    struct     -    The fixed-format struct which contains the data
%                                   
%
% See Also:
%   
% Example:
%   Data = ObjectCreate('Type','Raw');
%   

error(nargchk(1,inf,nargin));
error(nargoutchk(0,1,nargout));

if ~FIOProcessInputParameters(varargin,GetDefaultInput)
    error('The function input is not FlexIO compatible');
end

Data = [];
Data.Type = Type;
Data = ObjectAddSignature(Data,Signature);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DefaultInput  = GetDefaultInput
DefaultInput = {};

DefaultInput    =   FIOAddParameter(DefaultInput,'Type','Undefined'); 
DefaultInput    =   FIOAddParameter(DefaultInput,'Signature',mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

