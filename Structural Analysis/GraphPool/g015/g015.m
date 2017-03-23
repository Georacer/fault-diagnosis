classdef g015 < model
    
    methods
        function this = g015()
            this.name = 'g015';
            this.description = 'Model of a servo pulling a rope tied to a spring';
            
            con = [...
                {'inp theta_c theta'};...
                {'h theta'};...
                {'F h'};...
                {'msr F_m F'}
                ];
            this.constraints = [{con},{'c'}];
            
            this.coordinates = [];
        end
        
    end
    
end
