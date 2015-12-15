classdef Equation
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
        VariableArray = [];
        VariableAliasArray = {};
        FunctionArray = [];
        NumVars = 0;
        Coordinates = [0,0];
    end
    
    properties (Dependent)
        
    end
    
    methods
        
        function obj = Equation(exprStr)
            
            if (nargin==0)    
               
            elseif (nargin==1)
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
                operators = {'dot','int','ni','inp','out','msr'};
                isKnown = false;
                isMeasured = false;
                isInput = false;
                isOutput = false;
                isMatched = false;
                isDerivative = false;
                isIntegral = false;
                isNonSolvable = false;
                msrVar = false;
                words = strsplit(exprStr,' ');
                for i=1:size(words,2)
                    word = words{i};
                    opIndex = find(strcmp(operators, word));
                    if isempty(opIndex)
                        opIndex = -1;
                    end
                    if debug disp(sprintf('opIndex=%i',opIndex)); end
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
                            exists = false;
                            varIndex = find(strcmp(obj.VariableAliasArray,word));
                            if (inputVar) % It is an input variable
            %                     inputVar = false;
            %                     varIndex = find(strcmp(IVars,word));
            %                     if isempty(varIndex) % This input variable was not yet met
            %                         IVars = {IVars{:},word};
            %                         splitIndex = UVarsNo+IVarsNo;
            %                         IVarsNo = IVarsNo + 1;
            %                     else % This input variable already exists
            %                         entryIndex = UVarsNo + varIndex;
            %                         exists = true;
            %                     end
                            elseif (outputVar) % It is an output variable
            %                     outputVar = false;
            %                     varIndex = find(strcmp(OVars,word));
            %                     if isempty(varIndex) % This output variable was not yet met
            %                         OVars = {OVars{:},word};
            %                         splitIndex = UVarsNo+IVarsNo+OVarsNo;
            %                         OVarsNo = OVarsNo + 1;
            %                     else % This input variable already exists
            %                         entryIndex = UVarsNo + IVarsNo + varIndex;
            %                         exists = true;
            %                     end
                            elseif (msrVar)
                                msrVar = false;
                                varIndex = find(strcmp(KVars,word)); % Check if the variable is already met
                                if isempty(varIndex) % This known variable was not yet met
                                    KVars = [KVars,{word}];
                                    splitIndex = UVarsNo+KVarsNo; % Place the new variable at the end
                                    KVarsNo = KVarsNo + 1;
                                else % This input variable already exists
                                    entryIndex = UVarsNo + varIndex; % Place the variable in its correct index
                                    exists = true;
                                end                    
                            else % It is an unknown variable
                                varIndex = find(strcmp(UVars,word)); % Check if the variable is already met
                                if isempty(varIndex) % This output variable was not yet met
                                    UVars = [UVars, {word}];
                                    splitIndex = UVarsNo; % Place the new variable at the end of the unknown variables list
                                    UVarsNo = UVarsNo + 1;
                                else % This input variable already exists
                                    entryIndex = varIndex;
                                    exists = true;
                                end                   
                            end
                            
                            obj.VariableArray = [obj.VariableArray newVariable];
                            obj.updateVariableAliasArray;
                    end
                end
               
            end
            
        end
        
        function obj = updateVariableAliasArray(obj)
            obj.VariableAliasArray = cell(size(obj.VariableArray));
            for i=1:length(obj.VariableAliasArray)
                obj.VariableAliasArray{i} = obj.VariableArray[i].alias;
            end
        end
                
        function [] = disp(obj)
            fprintf('This is an equation class object');
        end
        
        function vars = getVars(obj)
            vars = obj.variableArray;
        end
    end
    
end