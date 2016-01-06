classdef IDProvider < matlab.mixin.Copyable
    %IDPROVIDER Provides unique IDs on demand
    
    properties (SetAccess = private)
        gh % Graph handle
        idCounter = 1; % Increasing counter
    end
    
    properties (Hidden = true)
        debug = true; % Debug messages flag
%         debug = false;
    end
    
    methods
        
        function this = IDProvider(graphHandle)
            gh = graphHandle;
        end
        
        function id = giveID(this)
            id = this.idCounter;
            this.idCounter = this.idCounter+1;
        end
        
    end
    
end

