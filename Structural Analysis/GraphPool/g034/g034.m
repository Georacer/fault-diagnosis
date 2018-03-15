classdef g034 < model
    
    methods
        function this = g034()
            this.name = 'g034';
            this.description = 'Benchmark model, to test graph segmentation functionality';
            
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
                ];
            
            der = [...
                ];
            
            dyn = [...
                ];
            % Set non-zero V, u
            
            msr = [...
                {'fault msr u x1'};...
                {'fault msr u x2'};...
                {'fault msr y x1'};...
                {'fault msr y x2'};...
                ];
            
            this.constraints = [...
                {kin},{'k'};...
                {der},{'d'};...
                {dyn},{'f'};...
                {msr},{'s'};...
                ];            
        end
        
    end
    
end