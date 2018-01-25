classdef g029 < model
% Toy model to test functionality of the FauDiaPy package

% Set up with the 2nd choice of sensor, as presented in the exaple script

    methods
        function this = g029()
            this.name = 'g029';
            this.description = 'Toy model for testing residual evaluation. Includes an algebraic scc';
            
            con = [...
                {'fault x1 x2 inp u1 expr -x1+2*x2+u1'};...
                {'fault x1 x2 inp u2 expr -x2-x1+u2'};...
                {'fault x3 x1 x2 expr -x3+x1-x2'};...
                {'fault x3 msr s1 expr -x3+s1'};...
                ];
            
            this.constraints = [...
                {con},{'c'};...
                ];
            
            this.coordinates = [];
            
        end
        
    end
    
end