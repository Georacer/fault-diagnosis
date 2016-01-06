function E = getEdges(gh)
% Returns an E(m,2) matrix, which lists all of the m edges of the graph
E = [];
for i=1:gh.numEdges
    flagE2V = true;
    flagV2E = true;
    varIndex = gh.getIndexById(gh.edges(i).varId);
    if gh.variables(varIndex).isKnown
        % No operation
    end
    if gh.variables(varIndex).isMeasured
        flagE2V = false;
    end
    if gh.variables(varIndex).isInput
        flagE2V = false; % From equation to variable
    end
    if gh.variables(varIndex).isOutput
        % No operation
    end
    if gh.edges(i).isMatched
        flagV2E = false; % From variable to equation
    end
    if gh.edges(i).isDerivative
        % No operation, unless causality says otherwise
    end
    if gh.edges(i).isIntegral
        % No operation, unless causality says otherwise
    end
    if gh.edges(i).isNonSolvable
        flagE2V = false; % From equation to variable
    end
    % Equation to Variable
    if flagE2V
        E(end+1,:) = [gh.edges(i).equId gh.edges(i).varId];
    end
    % Variable to Equation
    if flagV2E
        E(end+1,:) = [gh.edges(i).varId gh.edges(i).equId];
    end
end
end