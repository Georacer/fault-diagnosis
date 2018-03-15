classdef g031 < model
% Toy model for testing residual evaluation. Includes a DAE

    methods
        function this = g031()
            this.name = 'g031';
            this.description = 'Toy model for testing residual evaluation. Includes a DAE';
            
            con = [...
                {'fault dot_x1 x1 x2 x3 expr -dot_x1-5*x1+x2*x3'};...
                {'fault x2 x3 inp u1 expr -x2+x3*u1'};...
                {'fault x3 x2 x1 expr -4*x3-3*x2+x1'};...
                {'fault msr s1 ni x1 expr -s1+x1'};...
                {'int dot_x1 dot x1'};...
                ];
            
            this.constraints = [...
                {con},{'c'};...
                ];
            
            this.coordinates = [];
            
        end
        
    end
    
end