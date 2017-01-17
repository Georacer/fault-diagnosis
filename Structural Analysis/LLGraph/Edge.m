classdef Edge < GraphElement
    %EDGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        equId
        varId
        weight = 1;
    end
    
    properties (SetAccess = private)
        isDerivative = false;
        isIntegral = false;
        isNonSolvable = false;
    end
        
        methods
            
            function obj = Edge(id, equId, varId)
                obj = obj@GraphElement(id);
                obj.equId = equId;
                obj.varId = varId;
                
            end
            
            function setDerivative(obj,tf_value)
                obj.isDerivative = tf_value;
            end
            function setIntegral(obj,tf_value)
                obj.isIntegral = tf_value;
            end
            function setNonSolvable(obj,tf_value)
                obj.isNonSolvable = tf_value;
            end
        end
        
    end
    
