classdef g030 < model
% Toy model for testing residual evaluation. Includes an ODE

    methods
        function this = g030()
            this.name = 'g030';
            this.description = 'Toy model for testing residual evaluation. Includes an ODE';
            
            con = [...
                {'fault x1 inp u1 expr -x1+u1'};...
                {'fault dot_x2 x1 x2 inp u1 inp u2 expr -dot_x2+x1-2*x2+u1-u2'};...
                {'fault ni x2 msr s2 expr -x2+s2'};...
                {'int dot_x2 dot x2'};...
                ];
            
            this.constraints = [...
                {con},{'c'};...
                ];
            
            this.coordinates = [];
            
        end
        
    end
    
end