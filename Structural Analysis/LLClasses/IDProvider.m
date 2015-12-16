classdef IDProvider < handle
    %IDPROVIDER Provides unique IDs on demand
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        id = 1;
    end
    
    methods
        
        function obj = IDProvider()
        end
        
        function id = giveID(obj)
            id = obj.id;
            obj.id = obj.id+1;
        end
    end
    
end

