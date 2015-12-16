classdef Equation < handle
    %EQUATION Equation class definition
    %   Detailed explanation goes here
    
    properties
        Id = 1;
        Prefix = '';
        Alias = 'con';
        Expression
        ExpressionStructural
        Description
        IsStatic = false;
        IsDynamic = false;
        IsNonLinear = false;
        IsMatched = false;
        VariableArray = Variable.empty;
        FunctionArray
        NumVars = 0;
        Coordinates = [0,0];
    end
    
    properties (SetAccess = private)
        VariableAliasArray = {}        
    end
    
   
    methods
        
        % Constructor
        function obj = Equation(exprStr)
            
            if (nargin==0)
            end
               
            if (nargin>=1)
                % legend:
                % {} - normal term
                % dot - differential term
                % int - integral term
                % trig - trigonometric term
                % ni - general non-invertible term
                % inp - input variable % NOT SUPPORTED
                % out - output variable % NOT SUPPORTED
                % msr - measured variable
                debug = true;
                operators = {'dot','int','ni','inp','out','msr'}; % Available operators
                words = strsplit(exprStr,' '); % Split expression to operands and variables
                newVar = true; % New variable flag for properties initialization
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
                    end
                    word = words{i};
                    opIndex = find(strcmp(operators, word));
                    if isempty(opIndex)
                        opIndex = -1; % Found a new variable alias
                    end
%                     if debug disp(sprintf('opIndex=%i',opIndex)); end
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
                            if isemtpy(varIndex) % This variable was not yet met
                                tempVar = Variable();
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
                            else % We have already met this variable
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
            
        end
        
        % Update the array holding the variable objects
        function updateVariableAliasArray(obj)
            obj.VariableAliasArray = cell(size(obj.VariableArray));
            for i=1:length(obj.VariableAliasArray)
                obj.VariableAliasArray{i} = obj.VariableArray(i).alias;
            end
        end
           
        % Display function override
        function [] = disp(obj)
            fprintf('Equation object:\n');
            fprintf('name = %s\n',obj.Alias);
            fprintf('equations = [');
            fprintf('%s, ',obj.VariableAliasArray{:});
            fprintf(']\n');
        end
        
        % Return the referenced variables
        function vars = getVars(obj)
            vars = obj.VariableAliasArray;
        end
        
        % Set teh VariableArray property and update the ViarableAliaArray
        % property
        function set.VariableArray(obj,value)
            obj.VariableArray = value;
            obj.updateVariableAliasArray();            
        end
        
        % Disable the VariableAiasArray method - Not sure if this can work:
        % Is it used only on external calls?
%         function set.VariableAliasArray(obj)
%             warning('The VariableAliasArray structure is automatically updated on udpate of the VariableArray property');
%         end


        
    end
    
end