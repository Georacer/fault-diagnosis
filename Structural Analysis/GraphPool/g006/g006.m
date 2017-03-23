classdef g006 < model
    %% A graph which is over-constrained with loops allowed
    % But where ranking fails to perform maximum matching
    
    methods
        function this = g006()
            this.name = 'g006';
            this.description = 'A graph which is over-constrained with loops allowed, but where ranking fails to perform maximum matching';
            
            con = [...
                {'v2 dot v4 v5'};...
                {'v2 v3'};...
                {'v3 v5 v4'};...
                {'v4'};...
                {'v3 v5'};...
                {'v3'};...
                ];
            this.constraints = [{con},{'c'}];
            
            this.coordinates = [];
            
        end
        
    end
    
end
