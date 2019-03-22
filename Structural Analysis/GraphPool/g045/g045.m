classdef g045 < model
    
    methods
        function this = g045()
            this.name = 'g045';
            this.description = ['System to verify correct Branch and Bound algorithm behaviour when a Non-Invertible edge is matched in a dynamic loop'];
            
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
                {'fault dot_x1 x2'};
                {'ni x2 x1'};
                {'rg x1 x2'};
                ];
            
            der = [...
                {'dot x1 int dot_x1'};...
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