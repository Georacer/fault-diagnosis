classdef Integrator < Function
    %TESTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        state = 0;
        dt = 1;
    end
    
    methods
        function this = Integrator(deltaT)
            this.dt = deltaT;
            this.fh = @this.step;
        end
        
        function val = step(this,der)
            val = this.state + der*this.dt;
            this.state = val;
        end
        
        function reset(this)
            this.state = 0;
        end
    end
    
end

