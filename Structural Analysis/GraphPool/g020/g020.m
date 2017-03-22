classdef g020 < model
    
    methods
        function this = g020()
            this.name = 'g020';
            this.description = 'Benchmark for validation of BBILP matching. Cheapest matching has a NI and is invalid';
            
            con = [...
                {'fault ni x1'};...
                {'fault x1 x2'};...
                {'fault x1 x2 x3'};...
                {'fault x3 x2dot'};...
                {'dot x2 int x2dot'};...
                ];
            this.constraints = [{con},{'c'}];
            
            this.coordinates = [];
            
        end
        
    end
    
end