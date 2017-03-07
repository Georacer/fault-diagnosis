classdef Validator
    %VALIDATOR Class to validate bidirectional directed graph matchings
    %   Detailed explanation goes here
    
    properties
        graphDir = [];
        graphTypes = [];
        numVars = 0;
        numEqs = 0;
        DEF_INT = 2;
        DEF_DER = 3;
        DEF_NI = 4;
        DEF_AE = 5;
        
        debug = true;
%         debug = false;
        
    end
    
    methods
        function obj = Validator(BDMatched,BD_type,numVars,numEqs)
            obj.graphDir = BDMatched;
            obj.graphTypes = BD_type;
            obj.numVars = numVars;
            obj.numEqs = numEqs;
        end
        
        function resp = isValid(obj)
            % Break all integrations and differentiations
            if obj.debug; fprintf('Validator/isValid: Breaking derivations\n'); end
            graphDir_NoDynamics = obj.graphDir;
            graphTypes = obj.graphTypes;
            [intEdges_rows intEdges_cols] = find(graphTypes==obj.DEF_INT); % Find integral edges
            [derEdges_rows derEdges_cols] = find(graphTypes==obj.DEF_DER); % Find derivative edges
            for i=1:length(intEdges_rows) % Delete integral edges
                graphDir_NoDynamics(intEdges_rows(i),intEdges_cols(i)) = 0;
            end
            for i=1:length(derEdges_rows) % Delete derivative edges
                graphDir_NoDynamics(derEdges_rows(i),derEdges_cols(i)) = 0;
            end
            
            % Find all SCCs
            if obj.debug; fprintf('Validator/isValid: Finding SCCs\n'); end
            adjList = createAdjList(graphDir_NoDynamics); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            
            % If NI in SCC -> OK, nlsolver needed
            if obj.debug; fprintf('Validator/isValid: Checking for NIs in AEs\n'); end
            if ~isempty(SCCs) % If there are algebraic loops
                for i=1:length(SCCs) % For each one
                    if size(SCCs{i})==1 % Skip unit-size trivial SCCs
                        continue
                    end
                    AE = graphDir_NoDynamics;
                    vertices2Del = setdiff(1:size(AE,1),SCCs{i});
                    AE(vertices2Del,:) = []; % Delete unrelated vertices
                    AE(:,vertices2Del) = [];
                    if ~isempty(find(AE==obj.DEF_NI))
                        fprintf('Found a matched NI edge in an algebraic loop - NL solver required\n');
                    end
                end
            else
                fprintf('No algebraic SCCs found\n');
            end
            
            % Reduce the SCCs to single E-V pairs and re-connect integrations
            if obj.debug; fprintf('Validator/isValid: Reducing AEs in original graph\n'); end
            [graph_NoAE, types_NoAE, newNumVars, newNumEqs] = obj.reduceSCCs(obj.graphDir, obj.graphTypes, obj.numVars, obj.numEqs, SCCs);

            % Find all SCCs (These should be strictly dynamic)
            if obj.debug; fprintf('Validator/isValid: Finding SCCs\n'); end
            adjList = createAdjList(graph_NoAE); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            
            % Assert that all SCCs are dynamic
            if obj.debug; fprintf('Validator/isValid: Asserting all SCCs are dynamic\n'); end
            for i=1:length(SCCs)
                SCC = SCCs{i};
                if ~find(types_NoAE(SCC,SCC)==obj.DEF_INT)
                    error('This SCC should be dynamic but no integral edge found');
                end
                
            end
            
            % If NI in SCC -> NOT OK, because they do pure back-substitution
            % (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for NI edges in dynamic loops\n'); end
            if find(types_NoAE==obj.DEF_NI)
                error('Found Non-Invertible edge in a dynamic loop');
            end
            
            % If Integral->Derivative -> NOT OK, because derivative
            % causality in loop (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for derivative edges in dynamic loops\n'); end
            for i=1:length(SCCs)
                SCC=SCCs{i};
                tempTypes = types_NoAE(SCC,SCC);
                if find(tempTypes==obj.DEF_DER)
                    error('Found matched derivative edge in dynamic loop');
                end
            end
            
            % Reduce SCCs
            if obj.debug; fprintf('Validator/isValid: Reducing graph\n'); end
            [graph_NoSCC, types_NoSCC, newNumVars, newNumEqs] = obj.reduceSCCs(graph_NoAE, types_NoAE, newNumVars, newNumEqs, SCCs);
            
            % Find all paths
            if obj.debug; fprintf('Validator/isValid: Checking for SCCs\n'); end
            adjList = createAdjList(graph_NoSCC); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            if ~isempty(SCCs)
                error('This graph should not contain any loops');
            end            
            
            % If NI in path -> NOT OK (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for NI edges in paths\n'); end
            if find(types_NoSCC==obj.DEF_NI)
                error('This graph should not contain any Non-Invertible edges');
            end
            
            % If Derivative->Integral, NOT OK (FlAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for integral edges in paths\n'); end
            if find(types_NoSCC==obj.DEF_INT)
                error('This graph should not contain any Integral edges');
            end
            
        end
        
        function [graphReduced, typesReduced, newNumVars, newNumEqs] = reduceSCCs(obj, graph, types, numVars, numEqs, SCCs)
            % Delete trivial single-sized SCCs
            for i=length(SCCs):-1:1
                if length(SCCs{i})==1
                    SCCs(i) = [];
                end
            end
            
            oldVarIds = 1:numVars; % Assign ids for clarity when adding/deleting vertices
            oldEquIds = 1:numEqs;
            
            oldV2E = graph(1:numVars,numVars+1:end);
            oldE2V = graph(numVars+1:end,1:numVars);            
            oldV2E_types = types(1:numVars,numVars+1:end);
            oldE2V_types = types(numVars+1:end,1:numVars);
            
            varIdMap = 1:length(oldVarIds);
            equIdMap = 1:length(oldEquIds);
            SCCVarGroups = {};
            SCCEquGroups = {};
            vars2Keep = oldVarIds;
            eqs2Keep = oldEquIds;
            
            for i=1:length(SCCs) % Separate variable and equation IDs for each group;
                SCC = SCCs{i};
                SCCVars = SCC(SCC<=numVars);
                SCCEqs = SCC(SCC>numVars)-numVars;
                
                % Create id mappings
                varIdMap(SCCVars) = numVars + i;
                equIdMap(SCCEqs) = numEqs + i;
                
                SCCVarGroups{i} = SCCVars;
                SCCEquGroups{i} = SCCEqs;
                
                vars2Keep = setdiff(vars2Keep,SCCVarGroups{i});
                eqs2Keep = setdiff(eqs2Keep,SCCEquGroups{i});
            end
            newVarIds = [vars2Keep (1:length(SCCs))+numVars]; % Extend id arrays with new, reduced vertices
            newEquIds = [eqs2Keep (1:length(SCCs))+numEqs];
            newNumVars = length(newVarIds);
            newNumEqs = length(newEquIds);
            
            % Create old->new index mappings
            varIdxMap = zeros(size(varIdMap));
            for i=1:length(varIdxMap)
                varIdxMap(i) = find(newVarIds==varIdMap(i));
            end
            equIdxMap = zeros(size(equIdMap));
            for i=1:length(equIdxMap)
                equIdxMap(i) = find(newEquIds==equIdMap(i));
            end
            
            % Allocate the new reduced array
            newE2V = zeros(newNumEqs, newNumVars);
            newV2E = zeros(newNumVars, newNumEqs);
            newE2V_types = zeros(newNumEqs, newNumVars);
            newV2E_types = zeros(newNumVars, newNumEqs);
            
            % Convert old V2E edges to new V2E            
            [rowIdx, colIdx] = find(oldV2E);
            for i=1:length(rowIdx)
                newV2E(varIdxMap(rowIdx(i)),equIdxMap(colIdx(i))) = 1;
                newV2E_types(varIdxMap(rowIdx(i)),equIdxMap(colIdx(i))) = oldV2E_types(rowIdx(i),colIdx(i));
%                 assert(ismember(oldV2E_types(rowIdx(i),colIdx(i)),[1 obj.DEF_NI]),'Algebraic SCCs should not have derivative/integral connections');
            end
            
            % Convert old E2V edges to new E2V
            [rowIdx, colIdx] = find(oldE2V);
            for i=1:length(rowIdx)
                newE2V(equIdxMap(rowIdx(i)),varIdxMap(colIdx(i))) = 1;
                newE2V_types(equIdxMap(rowIdx(i)),varIdxMap(colIdx(i))) = oldE2V_types(rowIdx(i),colIdx(i));
%                 assert(ismember(oldE2V_types(rowIdx(i),colIdx(i)),[1 obj.DEF_NI]),'Algebraic SCCs should not have derivative/integral connections');
            end
            
            % Concatenate arrays to build overall directed graph
            graphReduced = [zeros(size(newV2E,1)) newV2E; newE2V zeros(size(newE2V,1))];
            typesReduced = [zeros(size(newV2E_types,1)) newV2E_types; newE2V_types zeros(size(newE2V_types,1))];
            
        end
                
        function [cycles,cycleTypes] = findCycles(obj)
            % Find cycles on the matched subproblem
            graph = obj.graphDir~=inf;
            [~, cycles] = find_elem_circuits(graph);
            
            cycleTypes = cell(size(cycles));
            
            for i=1:length(cycles)
                sequence = cycles{i};
                types = zeros(1,length(sequence-1));
                for j=1:(length(sequence)-1)
                    types(j) = obj.graphTypes(sequence(j),sequence(j+1));
                end
                cycleTypes{j} = types;
            end            
        end
        
    end
    
end

