function createAdjacency(obj)
% Create the graph adjacency matrix
numVars = obj.numVars;
numEqs = obj.numEqs;
numEls = numVars + numEqs;
adjacency = zeros(numEls,numEls);
for i=1:length(obj.equationArray)
    for j=1:length(obj.variableArray)
        varId = obj.variableIdArray(j);
        index = find(obj.equationArray(i).variableIdArray==varId); % Check if variable is contained in this equation
        if obj.debug fprintf('GRA: (%d,%d) Found %d instance(s) of %s in %s\n',i,j,length(index), obj.variableArray(j).prAlias,obj.equationArray(i).prAlias); end
        if ~isempty(index) % If yes, fill the corresponding cells accordingly
            % General case
            adjacency(numVars+i,j) = 1; % From equation to variable
            adjacency(j,numVars+i) = 1; % From variable to equation
            if obj.equationArray(i).variableArray(index).isKnown % TODO specify mutually exclusive properties
                % No operation
            end
            if obj.equationArray(i).variableArray(index).isMeasured
                adjacency(numVars+i,j) = 0; % From equation to variable
            end
            if obj.equationArray(i).variableArray(index).isInput
                % No operation
            end
            if obj.equationArray(i).variableArray(index).isOutput
                % No operation
            end
            if obj.equationArray(i).variableArray(index).isMatched
                adjacency(j,numVars+i) = 0; % From variable to equation
            end
            if obj.equationArray(i).variableArray(index).isDerivative
                % No operation, unless causality says otherwise
            end
            if obj.equationArray(i).variableArray(index).isIntegral
                % No operation, unless causality says otherwise
            end
            if obj.equationArray(i).variableArray(index).isNonSolvable
                adjacency(numVars+i,j) = 0; % From equation to variable
            end
        end
    end
end

obj.adjacency(end+1) = Adjacency(adjacency,obj.equationAliasArray,obj.equationIdArray,obj.variableAliasArray,obj.variableIdArray);

end