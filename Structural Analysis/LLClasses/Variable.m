classdef Variable < handle
    %VARIABLE Variable class definition
    %   Detailed explanation goes here
    
    properties
        id
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
    
    methods
        
        % Constructor
        function obj = Variable(id,alias,name,prefix,description)
            if nargin>=1
                obj.id = id;
            end
            if nargin>=2
                obj.alias = alias;
            end
            if nargin>=3
                obj.name = name;
            end
            if nargin>=4
                obj.prefix = prefix;
            end
            if nargin>=5
                obj.description = description;
            end
        end
        
        % Display override for Varible class
        function obj = disp(obj)
            fprintf('Variable object:\n');
            fprintf('id = %d\n',obj.id);
            fprintf('alias = %s\n',obj.alias);
            fprintf('description = %s\n',obj.description);          
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

