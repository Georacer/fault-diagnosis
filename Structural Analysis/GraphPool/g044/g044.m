classdef g044 < model
    
    methods
        function this = g044()
            this.name = 'g044';
            this.description = ['System to verify correct Branch and Bound algorithm behaviour when a Derivative Edge is matched in a dynamic loop'];
            
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
                {'fault x_1 x_2 x_3'};
                {'x_1 x_2'};
                {'ni x_3'};
                {'x_3 dot_x_1'};
                ];
            
            der = [...
                {'dot x_1 int dot_x_1'};...
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