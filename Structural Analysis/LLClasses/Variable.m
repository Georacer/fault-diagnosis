classdef Variable < matlab.mixin.Copyable
    %VARIABLE Variable class definition
    %   Initialization arguments:
    %       ID:
    %       ALIAS:
    %       PREFIX:
    %       NAME:
    %       DESCRIPTION: 
    
    properties
        id = 0;
        alias = 'var';
        name
        prefix = '';
        description
        isKnown
        isMeasured
        isInput
        isOutput
        isMatched = false;
        isDerivative
        isIntegral
        isNonSolvable
        coordinates
        rank = inf;
    end
    
    properties (Dependent)
        prAlias
    end
    
    properties (Hidden = true)
        debug = false;
%         debug = true;
    end
    
    methods
        
        function obj = Variable(id,alias,prefix,name,description)
        % Constructor
            global IDProviderObj;
            
            % Set Alias property
            if nargin>=2
                obj.alias = alias;
            end
            
            % Set Prefix property
            if nargin>=3
                obj.prefix = prefix;
            end
            
            % Set Id property
            if nargin>=1
                if ~isempty(id)
                    obj.id = id;
                elseif ~isempty(IDProviderObj) % An ID provider object has been declared
                    obj.id = IDProviderObj.giveID(obj);
                    if obj.debug
                        fprintf('VAR: Acquired ID %d from provider\n', obj.id);
                    end
                end
            end

            % Set Name property
            if nargin>=4
                obj.name = name;
            end
            
            % Set Description property
            if nargin>=5
                obj.description = description;
            end
        end
        
        function disp(obj)
        % Display override for Varible class
            fprintf('Variable object:\n');
            fprintf('id = %d\n',obj.id);
            fprintf('prefix = %s\n',obj.prefix);
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
        
        function propertyOR(obj,property,value)
        % Logical OR for properties
            if isprop(obj,property)
                obj.propertyTestEmpty(property);
                obj.(property) = obj.(property) | value;
            else
                error('Unknown variable property %s',property);
            end
        end
        
        function propertyTestEmpty(obj,property)
        % Test if a property is unset (empty) and if yes, assign it to false
            if isprop(obj,property)
                if isempty(obj.(property))
                    obj.(property) = false;
                end
            else
                error('Unknown variable property %s',property);
            end
        end
        
        function prAlias = get.prAlias(obj)
            prAlias = [obj.prefix obj.alias];
        end
        
    end
    
end

