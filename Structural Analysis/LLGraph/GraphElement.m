classdef GraphElement < matlab.mixin.Copyable
    %GRAPHELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        id = 0;
    end
    
    properties (SetAccess = public)
        isMatched = false;
    end
    
    properties (Hidden = true)
        debug = false;
        %         debug = true;
    end
    
    methods
        function obj = GraphElement(id)
            % Assign an ID to the object
            if ~isempty(id)
                obj.id = id;
                if obj.debug; fprintf('Equation: Acquired ID %d from provider\n', obj.id); end
            else
                error('Equation: Empty ID given');
            end
        end
        
        function setMatched(obj,tf_value)
            obj.isMatched = tf_value;
        end
        
        function resp = getProperties(this)
            resp = properties(this);
        end
    end
    
end

