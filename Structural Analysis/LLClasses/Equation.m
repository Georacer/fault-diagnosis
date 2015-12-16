classdef Equation < handle
    %EQUATION Equation class definition
    %   Initializaion arguments:
    %       ID:
    %       EXPRSTR:
    %       ALIAS:
    %       PREFIX:
    
    properties
        Id = 0;
        Prefix = '';
        Alias = 'con';
        ExpressionStructural
        Expression
        Description
        IsStatic = false;
        IsDynamic = false;
        IsNonLinear = false;
        IsMatched = false;
        VariableArray = Variable.empty;
        FunctionArray
        Coordinates = [0,0];
    end
    
    properties (SetAccess = private)
        VariableAliasArray = {};
        debug = false;
    end
    
   
    methods
        
        % Constructor
        function obj = Equation(id, exprStr, alias, prefix)
            global IDProviderObj;

            if (nargin==0)
                error('No arguments provided to Equation constructor');
            end
            
            if nargin>=1
                if ~isempty(id)
                    obj.Id = id;
                elseif ~isempty(IDProviderObj) % An ID provider object has been declared
                    obj.Id = IDProviderObj.giveID();
                    if obj.debug
                        fprintf('*** Acquired new ID from provider');
                    end
                end
            end
            
            % If a structural expression is provided, parse it
            if (nargin>=2)
                % Parse structural expression
                obj.ExpressionStructural = exprStr;
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
                    if obj.debug disp(sprintf('opIndex=%i',opIndex)); end
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
                            varIndex = find(strcmp(obj.VariableAliasArray,word));
                            if isempty(varIndex) % This variable was not yet met
                                tempVar = Variable([],word);
                                tempVar.isKnown = isKnown;
                                tempVar.isMeasured = isMeasured;
                                tempVar.isInput = isInput;
                                tempVar.isOutput = isOutput;
                                tempVar.isMatched = [];
                                tempVar.isDerivative = isDerivative;
                                tempVar.isIntegral = isIntegral;
                                tempVar.isNonSolvable = isNonSolvable;
                                obj.VariableArray(end+1) = tempVar;
                                obj.updateVariableAliasArray;
                            else % We have already met this variable, add its properties
                                obj.VariableArray(varIndex).propertyOR('isKnown',isKnown);
                                obj.VariableArray(varIndex).propertyOR('isMeasured',isMeasured);
                                obj.VariableArray(varIndex).propertyOR('isInput',isInput);
                                obj.VariableArray(varIndex).propertyOR('isOutput',isOutput);
                                obj.VariableArray(varIndex).propertyOR('isDerivative',isDerivative);
                                obj.VariableArray(varIndex).propertyOR('isIntegral',isIntegral);
                                obj.VariableArray(varIndex).propertyOR('isNonSolvable',isNonSolvable);
                            end
                            
                            initProperties = true;
                            
                    end
                end
               
            end
            
            % If an alias is provided...
            if nargin>=3
                obj.Alias = alias;
            end
            
        end
        
        % Update the array holding the variable objects
        function updateVariableAliasArray(obj)
            obj.VariableAliasArray = cell(size(obj.VariableArray));
            for i=1:length(obj.VariableAliasArray)
                obj.VariableAliasArray{i} = obj.VariableArray(i).alias;
            end
        end
           
        % Display function override
        function disp(obj)
            fprintf('Equation object:\n');
            fprintf('ID = %d\n',obj.Id);
            fprintf('name = %s\n',obj.Alias);
            fprintf('structural expression = %s\n',obj.ExpressionStructural);
            fprintf('variables = [');
            fprintf('%s, ',obj.VariableAliasArray{:});
            fprintf(']\n');
        end
        
        % Print each variable contained in this equation
        function dispVars(obj)
            fprintf('Variables contained in equation %s:\n',obj.Alias);
            for i=1:length(obj.VariableArray)
                fprintf('*Variable %d:\n',i);
                obj.VariableArray(i).dispDetailed();
            end
        end
        
        % Return the referenced variables
        function vars = getVars(obj)
            vars = obj.VariableAliasArray;
        end
        
        % Set the VariableArray property and update the ViarableAliaArray
        % property
        function set.VariableArray(obj,value)
            obj.VariableArray = value;
            obj.updateVariableAliasArray(); % Update the variable aliases array
        end
        
    end
    
end