classdef g043 < model
    
    methods
        function this = g043()
            this.name = 'g043';
            this.description = ['System to verify correct Branch and Bound algorithm behaviour when a NonInvertible edge is matched in a path'];
            
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
                {'fault x_1'};
                {'x_1 x_2'};
                {'ni x_3 ni x_2'};
                {'x_2 ni x_3'};
                ];
            
            der = [...
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