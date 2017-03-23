classdef Equation < Vertex
    %EQUATION Equation class definition
    %   Initialization arguments:
    %       ID:
    %       EXPRSTR:
    %       ALIAS:
    %       PREFIX:
    
    properties
    end
    
    properties (SetAccess = public)
        isStatic = false;
        isDynamic = false;
        isNonLinear = false;
        isResGenerator = false;
        isFaultable = false;
    end
   
    methods
        
        function obj = Equation(id, alias, description)
            % Constructor
            obj = obj@Vertex(id);
            
            if (nargin==0)
                error('No arguments provided to Equation constructor');
            end
            
            % If an alias is provided...
            if nargin>=2
                if ~isempty(alias)
                    obj.alias = alias;
                else
                    obj.alias = 'con';
                end
            end
            
            % If a description is provided
            if nargin>=3
                obj.description = description;
            end
        end
        
        
        function setStatic(obj,tf_value)
            obj.isStatic = tf_value;
            obj.isDynamic = ~tf_value;
        end
        function setDynamic(obj,tf_value)
            obj.istDynamic = tf_value;
            obj.isStatic = ~tf_value;
        end
        function setNonLinear(obj,tf_value)
            obj.isNonLinear = tf_value;
        end
        function setResGenerator(obj,tf_value)
            obj.isResGenerator = tf_value;
        end
        function setFaultable(obj,tf_value)
            obj.isFaultable = tf_value;
        end
        
        %%
        function disp(obj)
        % Display function override
            fprintf('Equation object:\n');
            fprintf('ID = %d\n',obj.id);
            fprintf('name = %s\n',obj.alias);
        end

    end
    
end