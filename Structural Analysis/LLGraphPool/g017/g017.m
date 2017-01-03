classdef g017 < model
    
    methods
        function this = g017()
            this.name = 'g017';
            this.description = 'Unit test to verify MTES functionality';
            
            %% legend:
            % dot - differential relation
            % int - integral term
            % trig - trigonometric term
            % ni - general non-invertible term
            % inp - input variable
            % out - output variable % NOT SUPPORTED
            % msr - measured variable
            
            %% Equations
            
            % Position derivatives
            equ = [...
                {'x1'};...
                {'x1 ni x2'};...
                {'fault x2'};...
                ];
            
            der = [...
                {'int dot_x1 dot x1'};...
                ];
            
            %% Summing up
            this.constraints = [...
                {equ},{'f'};...
                ];
            
            %% Specifying node coordinates if available
            this.coordinates = [];
            
        end
        
    end
    
end