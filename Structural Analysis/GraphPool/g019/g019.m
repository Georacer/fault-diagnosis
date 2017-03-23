classdef g019 < model
    
    methods
        function this = g019()
            this.name = 'g019';
            this.description = 'Benchmark for validation of edges in cyclces. Contains a forced NI edge in an algebraic loop.';
            
            con = [...
                {'fault ni x1 ni x2'};...
                {'fault x1 x2'};...
                {'fault ni x2'};...
                ];
            this.constraints = [{con},{'c'}];
            
            this.coordinates = [];
            
        end
        
    end
    
end