classdef Differentiator < Function
    %TESTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x_prev = 0;
        dt = 1;
    end
    
    methods
        function this = Differentiator(deltaT)
            this.dt = deltaT;
            this.fh = @this.step;
        end
        
        function der = step(this,x)
            der = (x - this.x_prev)/dt;
            this.x_prev = x;
        end
    end
    
end

