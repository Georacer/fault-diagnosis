classdef Equation < Node
    %EQUATION Equation class definition
    %   Initialization arguments:
    %       ID:
    %       EXPRSTR:
    %       ALIAS:
    %       PREFIX:
    
    properties
        prefix = '';
        expressionStructural
        expression
        isStatic = false;
        isDynamic = false;
        isNonLinear = false;
        isResGenerator = false;
        functionArray = {};
    end
    
    properties (Hidden = true)
        debug = false;
%         debug = true;
    end
    
    properties (Dependent)
        prAlias
    end
    
    properties (SetAccess = private)
        propertyList
    end
   
    methods
        
        function obj = Equation(id, alias, prefix, expressionStructural, name, description, expression)
        % Constructor

            if (nargin==0)
                error('No arguments provided to Equation constructor');
            end
                
            % If an alias is provided...
            if nargin>=2
                if ~isempty(alias)
                    obj.alias = alias;
                else
                    alias = 'con';
                end
            end
            
            % If a prefix is provided...
            if nargin>=3
                obj.prefix = prefix;
            end
            
            % Assign an ID to the object
            if nargin>=1
                if ~isempty(id)
                    obj.id = id;
                    if obj.debug fprintf('Equation: Acquired ID %d from provider\n', obj.id); end
                else
                    error('Equation: Empty ID given');
                end
            end
            
            % If a structural expression is provided, store it
            if (nargin>=2)
                obj.expressionStructural = expressionStructural;               
            end
            
            obj.propertyList = properties(obj);
                        
        end
        
        %%
        function disp(obj)
        % Display function override
            fprintf('Equation object:\n');
            fprintf('ID = %d\n',obj.id);
            fprintf('name = %s\n',obj.alias);
            fprintf('structural expression = %s\n',obj.expressionStructural);
        end
        
        %%
        function prAlias = get.prAlias(obj)
            prAlias = [obj.prefix obj.alias];
        end

    end
    
end