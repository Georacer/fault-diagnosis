classdef g046 < model
    
    methods
        function this = g046()
            this.name = 'g046';
            this.description = ['System to verify correct Branch and Bound algorithm behaviour when an integral edge is matched in a path'];
            
            %% Equation list
            % legend:
            % dot - differential relation
            % int - integral term
            % trig - trigonometric term
            % ni - general non-invertible term
            % inp - input variable
            % out - output variable % NOT SUPPORTED
            % msr - measured variable
            % sub - subsystem where the equation belongs
            % mat - matrix variable
            % expr - algebraic expression
            % par - parameter
            % dist - disturbance
            % rg - residual generator
            kin = [...
                {'fault dot_x'};
                {'dot_x ni x'};
                ];
            
            der = [...
                {'dot x int dot_x'};...
                ];
            
            msr = [...
                ];
            
            this.constraints = [...
                {kin},{'k'};...
                {der},{'d'};...
                {msr},{'s'};...
                ];            
        end
        
    end
    
end