classdef Equation < matlab.mixin.Copyable
    %EQUATION Equation class definition
    %   Initialization arguments:
    %       ID:
    %       EXPRSTR:
    %       ALIAS:
    %       PREFIX:
    
    properties
        id = 0;
        prefix = '';
        alias = 'con';
        expressionStructural
        expression
        description
        isStatic = false;
        isDynamic = false;
        isNonLinear = false;
        isMatched = false;
        variableArray = Variable.empty;
        functionArray
        coordinates = [0,0];
        rank = [];
    end
    
    properties (SetAccess = private)
        variableAliasArray = {};
        variableIdArray = [];
    end
    
    properties (Hidden = true)
        constructing = false;
        debug = false;
%         debug = true;
    end
    
    properties (Dependent)
        prAlias
        numVars
    end    
   
    methods
        
        function obj = Equation(id, exprStr, alias, prefix)
        % Constructor
            global IDProviderObj;
            obj.constructing = true; % Doing construction work

            if (nargin==0)
                error('No arguments provided to Equation constructor');
            end
                
            % If an alias is provided...
            if nargin>=3
                if ~isempty(alias)
                    obj.alias = alias;
                end
            end
            
            % If a prefix is provided...
            if nargin>=4
                obj.prefix = prefix;
            end
            
            % Assing an ID to the object
            if nargin>=1
                if ~isempty(id)
                    obj.id = id;
                elseif ~isempty(IDProviderObj) % An ID provider object has been declared
                    obj.id = IDProviderObj.giveID(obj);
                    
                    if obj.debug fprintf('EQU: Acquired ID %d from provider\n', obj.id); end
                    
                end
            end
            
            % If a structural expression is provided, parse it
            if (nargin>=2)
                % Parse structural expression
                obj.expressionStructural = exprStr;
                % legend:
                % {} - normal term
                % dot - differential term
                % int - integral term
                % trig - trigonometric term
                % ni - general non-invertible term
                % inp - input variable
                % out - output variable
                % msr - measured variable
                operators = {'dot','int','ni','inp','out','msr'}; % Available operators
                words = strsplit(exprStr,' '); % Split expression to operands and variables
                initProperties = true; % New variable flag for properties initialization
                for i=1:size(words,2)
                    if initProperties
                        isKnown = false;
                        isMeasured = false;
                        isInput = false;
                        isOutput = false;
                        isMatched = false;
                        isDerivative = false;
                        isIntegral = false;
                        isNonSolvable = false;
                        initProperties = false;
                    end
                    word = words{i};
                    opIndex = find(strcmp(operators, word));
                    if isempty(opIndex)
                        opIndex = -1; % Found a new variable alias
                    end
                    
                    if obj.debug disp(sprintf('EQU: opIndex=%i',opIndex)); end
                    
                    switch opIndex % Test if the word is an operator
                        case 1
                            isDerivative = true;
                        case 2
                            isIntegral = true;
                        case 3
                            isNonSolvable = true;
                        case 4
                            isInput = true;
                            isKnown = true;
                        case 5
                            isOutput = true;
                        case 6
                            isMeasured = true;
                            isKnown = true;
                        otherwise % Found a variable
                            % Lookup the variable
                            varIndex = find(strcmp(obj.variableAliasArray,word));
                            if isempty(varIndex) % This variable was not yet met
                                tempVar = Variable([],word,obj.prefix);
                                tempVar.isKnown = isKnown;
                                tempVar.isMeasured = isMeasured;
                                tempVar.isInput = isInput;
                                tempVar.isOutput = isOutput;
                                tempVar.isMatched = [];
                                tempVar.isDerivative = isDerivative;
                                tempVar.isIntegral = isIntegral;
                                tempVar.isNonSolvable = isNonSolvable;
                                obj.variableArray(end+1) = tempVar;
                                obj.variableAliasArray{end+1} = word;
                            else % We have already met this variable, add its properties
                                obj.variableArray(varIndex).propertyOR('isKnown',isKnown);
                                obj.variableArray(varIndex).propertyOR('isMeasured',isMeasured);
                                obj.variableArray(varIndex).propertyOR('isInput',isInput);
                                obj.variableArray(varIndex).propertyOR('isOutput',isOutput);
                                obj.variableArray(varIndex).propertyOR('isDerivative',isDerivative);
                                obj.variableArray(varIndex).propertyOR('isIntegral',isIntegral);
                                obj.variableArray(varIndex).propertyOR('isNonSolvable',isNonSolvable);
                            end
                            
                            initProperties = true;
                            
                    end
                end
               
            end
            obj.updateVariableIdArray();
            obj.constructing = false;
            
        end
        
        %%
        function updateVariableAliasArray(obj)
        % Update the array holding the variable objects aliases
            obj.variableAliasArray = cell(size(obj.variableArray));
            for i=1:length(obj.variableAliasArray)
                obj.variableAliasArray{i} = obj.variableArray(i).alias;
            end
        end
        
        function updateVariableIdArray(obj)
        % Update the array holding the equation objects IDs
            obj.variableIdArray = zeros(size(obj.variableArray));
            for i=1:length(obj.variableIdArray)
                obj.variableIdArray(i) = obj.variableArray(i).id;
            end
        end
           
        function disp(obj)
        % Display function override
            fprintf('Equation object:\n');
            fprintf('ID = %d\n',obj.id);
            fprintf('name = %s\n',obj.alias);
            fprintf('structural expression = %s\n',obj.expressionStructural);
            fprintf('variables = [');
            fprintf('%s, ',obj.variableAliasArray{:});
            fprintf(']\n');
        end
        
        function dispVars(obj)
        % Print each variable contained in this equation
            fprintf('Variables contained in equation %s:\n',obj.alias);
            for i=1:length(obj.variableArray)
                fprintf('*Variable %d:\n',i);
                obj.variableArray(i).dispDetailed();
            end
        end
        
        function vars = getVars(obj)
        % Return the referenced variables
            vars = obj.variableAliasArray;
        end
        
        function set.variableArray(obj,value)
        % Set the VariableArray property and update the ViarableAliaArray property
            obj.variableArray = value;
            if ~obj.constructing
                obj.updateVariableAliasArray(); % Update the variable aliases array
                obj.updateVariableIdArray(); % Update the varible IDs array
            end
        end
        
        %%
        function prAlias = get.prAlias(obj)
            prAlias = [obj.prefix obj.alias];
        end
        
        %%
        function num = get.numVars(obj)
            num = length(obj.variableArray);
        end
        
    end
    
end