classdef Edge
    %EDGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        equId
        varId
        isMatched = false;
        isDerivative = false;
        isIntegral = false;
        isNonSolvable = false;
    end
    
    properties (SetAccess = private)
        propertyList
    end
    
    methods
        
        function obj = Edge(id, equId, varId)
            
           obj.id = id;
           obj.equId = equId;
           obj.varId = varId;
           
           obj.propertyList = properties(obj);
            
        end
    end
    
end

