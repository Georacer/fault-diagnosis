classdef Integrator < Function
    %TESTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function val = evaluate(this,der)
            val = this.state + der{:}*this.dt;
            this.state = val;
        end
        
    end
    
end

