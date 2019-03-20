classdef g042 < model
    
    methods
        function this = g042()
            this.name = 'g042';
            this.description = ['System to verify correct Branch and Bound algorithm behaviour'];
            
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
                {'fault x_2'};
                {'fault ni x_1 x_2'};
                {'fault ni x_1 x_2'};
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