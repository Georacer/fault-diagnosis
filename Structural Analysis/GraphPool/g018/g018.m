classdef g018 < model
    
    methods
        function this = g018()
            this.name = 'g018';
            this.description = 'Benchmark for comparison of MSOs vs MTEs';
            % According to Krysander, M., Aslund, J., & Frisk, E. (2010). A Structural Algorithm for Finding Testable Sub-models and Multiple Fault Isolability Analysis. 21st International Workshop on the Principles of Diagnosis.
            % There should be only one MTES for this graph but 3 MSOs
            
            % This is true and the returned MTES is {1 2 3 4}, which is NOT
            % an MSO.
            con = [...
                {'x1'};...
                {'fault x1 x2'};...
                {'x2'};...
                {'x2'};...
                ];
            this.constraints = [{con},{'c'}];
            
            this.coordinates = [];
            
        end
        
    end
    
end