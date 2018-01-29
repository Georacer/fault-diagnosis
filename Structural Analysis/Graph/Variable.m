classdef Variable < Vertex
    %VARIABLE Variable class definition
    %   Initialization arguments:
    %       ID:
    %       ALIAS:
    %       PREFIX:
    %       NAME:
    %       DESCRIPTION: 
    
    properties (SetAccess = public)
        isKnown
        isMeasured
        isInput
        isOutput
        isResidual
        isMatrix
        isFault
    end
        
    methods
        
        function this = Variable(id,alias,description)
            this = this@Vertex(id);
        % Constructor
                    
            % Set Alias property
            if nargin>=2
                this.alias = alias;
            end
            
            % Set Description property
            if nargin>=3
                this.description = description;
            end
            
        end
        
        function disp(this)
        % Display override for Varible class
            fprintf('Variable object:\n');
            fprintf('id = %d\n',this.id);
            fprintf('alias = %s\n',this.alias);
            fprintf('description = %s\n',this.description);          
        end
        
        function dispDetailed(this)
            fprintf('Variable object:\n');
            fprintf('|-id = %d\n',this.id);
            fprintf('|-alias = %s\n',this.alias);
            fprintf('|-description = %s\n',this.description);             
            fprintf('|-isKnown = %d\n',this.isKnown);
            fprintf('|-isMeasured = %d\n',this.isMeasured);
            fprintf('|-isInput = %d\n',this.isInput);
            fprintf('|-isOutput = %d\n',this.isOutput);
            fprintf('|-matchedTo = %d\n',this.matchedTo);
        end
        
        function setKnown(obj,tf_value)
            obj.isKnown= tf_value;
        end
        function setMeasured(obj,tf_value)
            obj.isMeasured= tf_value;
        end
        function setInput(obj,tf_value)
            obj.isInput= tf_value;
        end
        function setOutput(obj,tf_value)
            obj.isOutput= tf_value;
        end
        function setResidual(obj,tf_value)
            obj.isResidual= tf_value;
        end

    end
    
end

