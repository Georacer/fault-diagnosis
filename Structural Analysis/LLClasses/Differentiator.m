classdef Differentiator < Function
    %TESTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function der = evaluate(this,x)
            der = (x{:} - this.state)/this.dt;
            this.state = x{:};
        end
    end
    
end

