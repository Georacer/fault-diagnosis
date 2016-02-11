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
    if ~gh.isMatchable(gh.edges(i).id)
        flagE2V = false; % Equation to Variable
    end
    if flagE2V
        E(end+1,:) = [gh.edges(i).equId gh.edges(i).varId];
    end
    % Variable to Equation
    if flagV2E
        E(end+1,:) = [gh.edges(i).varId gh.edges(i).equId];
    end
end
end