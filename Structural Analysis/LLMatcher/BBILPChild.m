classdef BBILPChild < matlab.mixin.Copyable
    %BBILPCHILD Child node for the BBILP matching problem
    %   Detailed explanation goes here
    
    properties
        BD = [];
        E2V = [];
        BD_type = [];
        cost = inf;
        matching = [];
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
            nonInvertibleCost = 500;
            
            iCount = 1;
            for i=(obj.numVars+1):(obj.numVars+obj.numEqs)
                jCount = 1;
                for j=1:obj.numVars
                    equId = obj.equIdArray(iCount);
                    varId = obj.varIdArray(jCount);
                    
                    edgeId = gi.getEdgeIdByVertices(equId,varId);
                    if ~isempty(edgeId)
                        if gi.isIntegral(edgeId)
                            obj.BD(iCount,jCount) = integrationCost;
                            obj.BD_type(iCount,jCount) = 2;
                        elseif gi.isDerivative(edgeId)
                            obj.BD(iCount,jCount) = differentiationCost;
                            obj.BD_type(iCount,jCount) = 3;
                        elseif gi.isNonSolvable(edgeId)
                            obj.BD(iCount,jCount) = nonInvertibleCost;
                            obj.BD_type(iCount,jCount) = 4;
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
            end
        end
        
        function setCost(obj,cost)
            obj.cost = cost;
        end
        
        function setMatching(obj,matching)
            obj.matching = matching;
        end
        
        function findMatching(obj)
            [permutations, cost] = munkres(obj.E2V);
            matching = [];
            iCounter = 1;
            for i=1:length(permutations)
                equId = obj.equIdArray(i);
                if ~permutations(i)
                    continue
                end
                varId = obj.varIdArray(permutations(i));
                edgeId = obj.gi.getEdgeIdByVertices(equId,varId);
                matching(iCounter) = edgeId;
                iCounter = iCounter+1;
            end
            obj.setMatching(matching);
            obj.setCost(cost);
        end
        
        function resp = isMatchingValid(obj)
            % TODO: Change validity conditions
            if all(obj.gi.isMatchable(obj.matching))
                resp = true;
            else
                resp = false;
            end
        end
        
        function childObj = createChild(obj)
            childObj = copy(obj);
            childObj.depth = obj.depth+1;
        end
        
        function cycles = findCycles(obj)
            
        end
    end
    
end
