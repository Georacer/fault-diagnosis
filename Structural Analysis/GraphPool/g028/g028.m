classdef g028 < model
% Toy model to test functionality of the FauDiaPy package

% Set up with the 2nd choice of sensor, as presented in the exaple script

    methods
        function this = g028()
            this.name = 'g028';
            this.description = 'Toy model for testing FauDiaPy. Includes an open-loop differentiation';
            
            con = [...
                {'fault x1 inp u1 expr -x1+u1'};...
                {'fault x2 inp u1 inp u2 expr -x2+u1+u2'};...
                {'fault x3 x1 x2 expr -x3+x1-x2'};...
                {'dot dot_x3 int x3'};...
                {'fault dot_x3 msr s3 expr -dot_x3+s3'};...
                ];
            
            this.constraints = [...
                {con},{'c'};...
                ];
            
            this.coordinates = [];
            
        end
        
    end
    
end