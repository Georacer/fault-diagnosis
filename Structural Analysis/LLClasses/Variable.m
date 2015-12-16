classdef Variable < handle
    %VARIABLE Variable class definition
    %   Initialization arguments:
    %       ID:
    %       ALIAS:
    %       NAME:
    %       PREFIX:
    %       DESCRIPTION: 
    
    properties
        id = 0;
        alias
        name
        prefix
        description
        isKnown
        isMeasured
        isInput
        isOutput
        isMatched
        isDerivative
        isIntegral
        isNonSolvable
        coordinates
    end
    
    properties (SetAccess = private)
        debug = false;
    end
    
    methods
        
        % Constructor
        function obj = Variable(id,alias,name,prefix,description)
            global IDProviderObj;
            
            % Set Id property
            if nargin>=1
                if ~isempty(id)
                    obj.id = id;
                elseif ~isempty(IDProviderObj) % An ID provider object has been declared
                    obj.id = IDProviderObj.giveID();
                    if obj.debug
                        fprintf('*** Acquired new ID from provider');
                    end
                end
            end
            
            % Set Alias property
            if nargin>=2
                obj.alias = alias;
            end
            
            % Set Name property
            if nargin>=3
                obj.name = name;
            end
            
            % Set Prefix property
            if nargin>=4
                obj.prefix = prefix;
            end
            
            % Set Description property
            if nargin>=5
                obj.description = description;
            end
        end
        
        % Display override for Varible class
        function disp(obj)
            fprintf('Variable object:\n');
            fprintf('id = %d\n',obj.id);
            fprintf('alias = %s\n',obj.alias);
            fprintf('description = %s\n',obj.description);          
        end
        
        function dispDetailed(obj)
            fprintf('Variable object:\n');
            fprintf('|-id = %d\n',obj.id);
            fprintf('|-alias = %s\n',obj.alias);
            fprintf('|-description = %s\n',obj.description);             
            fprintf('|-isKnown = %d\n',obj.isKnown);
            fprintf('|-isMeasured = %d\n',obj.isMeasured);
            fprintf('|-isInput = %d\n',obj.isInput);
            fprintf('|-isOutput = %d\n',obj.isOutput);
            fprintf('|-isMatched = %d\n',obj.isMatched);
            fprintf('|-isDerivative = %d\n',obj.isDerivative);
            fprintf('|-isIntegral = %d\n',obj.isIntegral);
            fprintf('|-isNonSolvable = %d\n',obj.isNonSolvable);
        end
        
        % Logical OR for properties
        function propertyOR(obj,property,value)
            if isprop(obj,property)
                obj.propertyTestEmpty(obj,property);
                obj.(property) = obj.(property) | value;
            else
                error('Unknown variable property %s',property);
            end
        end
        
        % Test if a property is unset (empty) and if yes, assign it to
        % false
        function propertyTestEmpty(obj,property)
            if isprop(obj,property)
                if isempty(obj.(property))
                    obj.(property) = false;
                end
            else
                error('Unknown variable property %s',property);
            end
        end
        
    end
    
end

