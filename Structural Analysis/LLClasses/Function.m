classdef Function < handle
    %FUNCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fh = function_handle.empty;
        state = 0;
        dt = [];
    end
    
    methods
        
        function result = evaluate(this, inputCell)
            if isempty(this.fh)
                error('No function handle defined');
            else
                result = feval(this.fh, inputCell{:});
            end
        end
    end
    
end

