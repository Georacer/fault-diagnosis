classdef g038 < model
    
    methods
        function this = g038()
            this.name = 'g038';
            this.description = 'Algebraic nonlinear model to test fault and disturbance effect to residual';
            
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
            kin = [...
                {'x_1 x_2 f_1 expr x_1-x_2*(f_1+1)'};...
                {'msr y_1 x_1 dist d_1 expr y_1-x_1*x_1-d_1'};...
                {'msr y_2 x_1 x_2 dist d_2 expr y_2-x_1*x_2-d_2'};...
                ];
            
            der = [...
                ];
            
            flt = [...
                {'fault f_1 expr f_1'};
                ];
            
            msr = [...
                ];
            
            this.constraints = [...
                {kin},{'k'};...
                {der},{'d'};...
                {flt},{'f'};...
                {msr},{'s'};...
                ];            
        end
        
    end
    
end