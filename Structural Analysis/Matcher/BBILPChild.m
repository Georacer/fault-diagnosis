classdef BBILPChild < matlab.mixin.Copyable
    %BBILPCHILD Child node for the BBILP matching problem
    %   Detailed explanation goes here
    
    properties
        BD = [];
        BDMatched = [];
        E2V = [];
        BD_type = [];
        cost = inf;
        matching = [];
        offendingEdges = [];
        edgesInhibited = [];
        equIdArray = [];
        varIdArray = [];
        numVars = 0;
        numEqs = 0;
        gi = GraphInterface.empty;
        
        depth = 0;
    end
    
    methods
        % Constructor
        function obj = BBILPChild(gi)
            obj.gi = gi;
            obj.varIdArray = gi.getVariablesUnknown;
            obj.equIdArray = gi.reg.equIdArray;
            obj.numVars = length(obj.varIdArray);
            obj.numEqs = length(obj.equIdArray);
            % BD array specification: First variables, then equations
            obj.BD = inf*ones(obj.numVars+obj.numEqs,obj.numVars+obj.numEqs);
            obj.BD_type = obj.BD;
            obj.E2V = inf*ones(obj.numEqs,obj.numVars);
            
            % Assertions
            assert(obj.numVars<=obj.numEqs,'Cannot match underconstrained graph');
            
            % Create directed graph edges
            obj.BD(logical(gi.adjacency.BD))=1;
            obj.BD_type(logical(gi.adjacency.BD))=1;
            
            integrationCost = 100;
            differentiationCost = 100;
            nonInvertibleCost = 1;
            
            iCount = 1;
            for i=(obj.numVars+1):(obj.numVars+obj.numEqs)
                jCount = 1;
                for j=1:obj.numVars
                    equId = obj.equIdArray(iCount);
                    varId = obj.varIdArray(jCount);
                    
                    edgeId = gi.getEdgeIdByVertices(equId,varId);
                    if ~isempty(edgeId)
                        if gi.isIntegral(edgeId)
                            obj.BD(iCount+obj.numVars,jCount) = integrationCost;
                            obj.BD_type(iCount+obj.numVars,jCount) = 2;
                        elseif gi.isDerivative(edgeId)
                            obj.BD(iCount+obj.numVars,jCount) = differentiationCost;
                            obj.BD_type(iCount+obj.numVars,jCount) = 3;
                        elseif gi.isNonSolvable(edgeId)
                            obj.BD(iCount+obj.numVars,jCount) = nonInvertibleCost;
                            obj.BD_type(iCount+obj.numVars,jCount) = 4;
                        else
                            % This is a normal edge
                        end
                    end
                    
                    jCount = jCount + 1;
                end
                iCount = iCount + 1;
            end
            
            obj.E2V = obj.BD((obj.numVars+1):end,1:obj.numVars);
            
        end
        
        function prohibitEdge(obj, edgeId)
            varId = obj.gi.getVariables(edgeId);
            equId = obj.gi.getEquations(edgeId);
            varIndex = find(obj.varIdArray==varId);
            equIndex = find(obj.equIdArray==equId);
            if (~isempty(varIndex))&&(~isempty(equIndex))
                obj.E2V(equIndex,varIndex) = inf;
                obj.BD(obj.numVars+equIndex,varIndex) = inf;
            end
            obj.edgesInhibited = [obj.edgesInhibited edgeId];
        end
        
        function setCost(obj,cost)
            obj.cost = cost;
        end
        
        function setMatching(obj,matching)
            obj.matching = matching;
        end
        
        function findMatching(obj)
            
            obj.BDMatched = obj.BD;
            obj.BDMatched(:,1:obj.numVars) = inf;
            
            [permutations, cost] = munkres(obj.E2V);
            matching = [];
            iCounter = 1;
            for i=1:length(permutations)
                if permutations(i) % Enter only if this equation is matched
                    % Disable the V2E direction for matched edges
                    obj.BDMatched(permutations(i),i+obj.numVars)=inf;
                    % Enable the E2V direction for matched edges
                    obj.BDMatched(i+obj.numVars,permutations(i))=1;
                    
                    % Find and store the matching edge id
                    equId = obj.equIdArray(i);
                    if ~permutations(i)
                        continue
                    end
                    varId = obj.varIdArray(permutations(i));
                    edgeId = obj.gi.getEdgeIdByVertices(equId,varId);
                    matching(iCounter) = edgeId;
                    iCounter = iCounter+1;
                end
            end
            obj.setMatching(matching);
            if length(matching)<obj.numVars % Matching is not complete on variables
                obj.setCost(inf);
            else
                obj.setCost(cost);
            end
            
        end
        
        function resp = isMatchingValid(obj)
            
            if length(obj.matching)<obj.numVars % No complete matching found]
                resp = false;
                obj.offendingEdges = [];
                return;
            end
            
            % Convert inf edges to 0
            graphDir = obj.BDMatched;
            graphDir(graphDir==inf) = 0;
            graphTypes = obj.BD_type;
            graphTypes(graphTypes==inf) = 0;
            
            validator = Validator(graphDir, graphTypes, obj.numVars, obj.numEqs);
            offendingEdges = validator.isValid();
            if isempty(offendingEdges)
                resp = true;
            else
                equIndices = offendingEdges(:,1);
                varIndices = offendingEdges(:,2);
                equIds = obj.equIdArray(equIndices);
                varIds = obj.varIdArray(varIndices);
                edgeIds = zeros(1,length(equIds));
                for i=1:length(edgeIds)
                    edgeIds(i) = obj.gi.getEdgeIdByVertices(equIds(i),varIds(i));
                end
                obj.offendingEdges = edgeIds;
                resp = false;
            end
        end
        
        function edgeIds = getOffendingEdges(obj)
            edgeIds = obj.offendingEdges;
        end
        
        function childObj = createChild(obj)
            childObj = copy(obj);
            childObj.depth = obj.depth+1;
        end

    end
    
end

