classdef g027 < model
% Toy model to test functionality of the FauDiaPy package

% Set up with the 2nd choice of sensor, as presented in the exaple script

    methods
        function this = g027()
            this.name = 'g027';
            this.description = 'Toy model for testing FauDiaPy.';
            
            con = [...
                {'fault x1 inp u1 expr -x1+u1'};...
                {'fault x2 inpu u1 inp u2 expr -x2+u1+u2'};...
                {'fault x3 x1 x2 expr -x3+x1-x2'};...
                {'fault x3 msr u3 expr -x3+u3'};...
                ];
            
            this.constraints = [...
                {con},{'c'};...
                ];
            
            this.coordinates = [];
            
        end
        
    end
    
end