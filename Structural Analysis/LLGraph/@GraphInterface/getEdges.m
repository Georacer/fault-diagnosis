function E = getEdges(gh, option)
% Returns an E(m,2) matrix, which lists all of the m edges of the graph
%OPTIONAL: option - [V2E, E2V] return only V2E/E2V edges

% debug = true;
debug = false;

noV2E = false;
noE2V = false;

if nargin==2
    if option == 'V2E'
        noE2V = true;
    elseif option == 'E2V'
        noV2E = true;
    else
        error('Unknown argument %s\n',option);
    end
end

E = [];
for i=1:gh.numEdges
    if debug fprintf('Examining edge with ID: %d ',gh.edges(i).id); end
    flagE2V = true;
    flagV2E = true;
    equId = gh.edges(i).equId;
    varId = gh.edges(i).varId;
    varIndex = gh.getIndexById(gh.edges(i).varId);
    if debug fprintf('linking equtation %d and variable %d\n',gh.edges(i).equId, gh.edges(i).varId); end
    if gh.variables(varIndex).isKnown
        % No operation
    end
    if gh.variables(varIndex).isMeasured
        flagE2V = false;
        if debug fprintf('The E->V direction is disabled, because the variable is measured\n'); end
    end
    if gh.variables(varIndex).isInput
        flagE2V = false; % From equation to variable
        if debug fprintf('The E->V direction is disabled, because the variable is an input\n'); end
    end
    if gh.variables(varIndex).isOutput
        % No operation
    end
    if gh.edges(i).isMatched
        flagV2E = false;
        if debug fprintf('The V->E direction is disabled, because the edge is matched\n'); end
    elseif gh.isMatched(varId)
        flagE2V = false;
        if debug fprintf('The E->V direction is disabled, because the variable is matched\n'); end
    elseif ~gh.isMatchable(gh.edges(i).id)
        flagE2V = false; % Equation to Variable
        if debug fprintf('The E->V direction is disabled, because the variable cannot be matched\n'); end
    end
    if flagE2V && ~noE2V
        E(end+1,:) = [gh.edges(i).equId gh.edges(i).varId gh.edges(i).weight]; % with added cost of solving the edge
    end
    % Variable to Equation
    if flagV2E && ~noV2E
        E(end+1,:) = [gh.edges(i).varId gh.edges(i).equId 0]; % V2E edges are free
    end
end
end