function E = getEdges(obj)
% Returns an E(m,2) matrix, which lists all of the m edges of the graph
E = [];
for i=1:obj.numEqs
    for j=1:obj.equationArray(i).numVars
        flagE2V = true;
        flagV2E = true;
        if obj.equationArray(i).variableArray(j).isKnown
            % No operation
        end
        if obj.equationArray(i).variableArray(j).isMeasured
            flagE2V = false;
        end
        if obj.equationArray(i).variableArray(j).isInput
            % No operation
        end
        if obj.equationArray(i).variableArray(j).isOutput
            % No operation
        end
        if obj.equationArray(i).variableArray(j).isMatched
            flagV2E = false; % From variable to equation
        end
        if obj.equationArray(i).variableArray(j).isDerivative
            % No operation, unless causality says otherwise
        end
        if obj.equationArray(i).variableArray(j).isIntegral
            % No operation, unless causality says otherwise
        end
        if obj.equationArray(i).variableArray(j).isNonSolvable
            flagE2V = false; % From equation to variable
        end
        % Equation to Variable
        if flagE2V
            E(end+1,:) = [obj.equationArray(i).id obj.equationArray(i).variableArray(j).id];
        end
        % Variable to Equation
        if flagV2E
            E(end+1,:) = [obj.equationArray(i).variableArray(j).id obj.equationArray(i).id];
        end
    end
end
end