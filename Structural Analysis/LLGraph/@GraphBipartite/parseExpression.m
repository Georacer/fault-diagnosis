function parseExpression( this, exprStr, alias, prefix )
%PARSEEXPRESSION Parse a structural expression
%   Parse a structural expression and create equation, variable and edge
%   objects in the calling graph object

% debug = true;
debug = false;

% Parse structural expression
[resp, equId] = this.addEquation([], alias, prefix, exprStr);
% this.equations(end+1) = Equation([],alias, prefix, exprStr);

% legend:
% {} - normal term
% dot - differential term
% int - integral term
% trig - trigonometric term
% ni - general non-invertible term
% inp - input variable
% out - output variable
% msr - measured variable
operators = {'dot','int','ni','inp','out','msr','fault'}; % Available operators
words = strsplit(exprStr,' '); % Split expression to operands and variables
linkedVariables = []; % Array with variables linked to this equation
initProperties = true; % New variable flag for properties initialization
for i=1:size(words,2)
    if initProperties
        isKnown = false;
        isMeasured = false;
        isInput = false;
        isOutput = false;
        isResidual = false;
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
    
    if debug disp(sprintf('parseExpression: opIndex=%i',opIndex)); end
    
    switch opIndex % Test if the word is an operator
        case 1
%             isDerivative = true;
            isIntegral = true;
        case 2
%             isIntegral = true;
            isDerivative = true;
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
        case 7
            this.setProperty(equId,'isFaultable');
        otherwise % Found a variable
            
            varProps.isKnown = isKnown;
            varProps.isMeasured = isMeasured;
            varProps.isInput = isInput;
            varProps.isOutput = isOutput;
            varProps.isResidual = isResidual;
            varProps.isMatched = isMatched;
            [resp, varId] = this.addVariable([],word,varProps);
            
            edgeProps.isMatched = false;
            edgeProps.isDerivative = isDerivative;
            edgeProps.isIntegral = isIntegral;
            edgeProps.isNonSolvable = isNonSolvable;
            this.addEdge([],equId,varId,edgeProps);
                
            initProperties = true;
            
    end
end

end

