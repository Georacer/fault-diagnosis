classdef Function
    %FUNCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fh = function_handle.empty;
        state = [];
        dt = [];
    end
    
    methods
        
        function result = evaluate(this, inputCell)
            if isempty(this.fh)
                error('No function handle defined');
            else
                [result, state] = feval(this.fh, inputCell{:}, this.state, this.dt);
                this.state = state;
            end
        end
    end
    
end

