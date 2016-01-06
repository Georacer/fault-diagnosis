classdef Variable < Node
    %VARIABLE Variable class definition
    %   Initialization arguments:
    %       ID:
    %       ALIAS:
    %       PREFIX:
    %       NAME:
    %       DESCRIPTION: 
    
    properties
        isKnown
        isMeasured
        isInput
        isOutput
        isResidual
    end
    
    properties (Hidden = true)
        debug = false;
%         debug = true;
    end
    
    properties (SetAccess = private)
        propertyList
    end
    
    methods
        
        function this = Variable(id,alias,name,description)
        % Constructor            
            % Set Alias property
            if nargin>=2
                this.alias = alias;
            end
            
            % Set Id property
            if nargin>=1
                if ~isempty(id)
                    this.id = id;
                    if (this.debug) fprintf('Variable: Acquired ID %d\n',id); end
                else
                    error('Variable: Empty id given');
                end
            end

            % Set Name property
            if nargin>=3
                this.name = name;
            end
            
            % Set Description property
            if nargin>=4
                this.description = description;
            end
            
            this.propertyList = properties(this);
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

    end
    
end

