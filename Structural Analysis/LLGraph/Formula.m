classdef Formula
    %FORMULA Class for evaluation of equations
    %   Detailed explanation goes here
    
    properties
        id % Same as the corresponding equation
        expressionString
        expressionStructural
        expressionSymbolic
        variableNames
    end
    
    methods
        function obj = Formula()
        end
        
        function result = getEvaluation(equId,varId)
        end
    end
    
end

