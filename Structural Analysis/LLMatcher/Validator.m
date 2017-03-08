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
        
        function offendingEdges = isValid(obj)
            
            offendingEdges = []; % Container for edges invalidating the matching
            
            
            % Break all integrations and differentiations
            if obj.debug; fprintf('Validator/isValid: Breaking derivations\n'); end
            graphDir_NoDynamics = obj.graphDir;
            graphTypes = obj.graphTypes;
            [intEdges_rows, intEdges_cols] = find(graphTypes==obj.DEF_INT); % Find integral edges
            [derEdges_rows, derEdges_cols] = find(graphTypes==obj.DEF_DER); % Find derivative edges
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
            originalVarIds = 1:length(obj.numVars);
            originalEquIds = 1:length(obj.numEqs);
            [graph_NoAE, types_NoAE, varIds_NoAE, equIds_NoAE, varIdMap_NoAE, equIdMap_NoAE] = obj.reduceSCCs(obj.graphDir, obj.graphTypes, originalVarIds, originalEquIds, SCCs);
            numVars_NoAE = length(varIds_NoAE);
            numEqs_NoAE = length(equIds_NoAE);            
            
            % Find all SCCs (These should be strictly dynamic)
            if obj.debug; fprintf('Validator/isValid: Finding SCCs\n'); end
            adjList = createAdjList(graph_NoAE); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            
            % Assert that all SCCs are dynamic
            if obj.debug; fprintf('Validator/isValid: Asserting all SCCs are dynamic\n'); end
            for i=1:length(SCCs)
                if size(SCCs{i})==1 % Skip unit-size trivial SCCs
                    continue
                end
                SCC = SCCs{i};
                if ~find(types_NoAE(SCC,SCC)==obj.DEF_INT)
                    error('This SCC should be dynamic but no integral edge found');
                end
                
            end
            
            % If NI in SCC -> NOT OK, because they do pure back-substitution
            % (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for NI edges in dynamic loops\n'); end
            for i=1:length(SCCs)
                if size(SCCs{i})==1 % Skip unit-size trivial SCCs
                    continue
                end
                SCC = SCCs{i};
                % Isolate E2V part
                varIndices = SCC(SCC<=numVars_NoAE);
                equIndices = SCC(SCC>numVars_NoAE)-numVars_NoAE; % Rebase equation indices to 1
                [row, col] = find(types_NoAE(equIndices,varIndices)==obj.DEF_NI);
                for i=1:length(row)
                    equId = equIds_NoAE(row(i));
                    varId = varIds_NoAE(col(i));
                    offendingEdges(end+1,:) = [equId varId];
                    if obj.debug; fprintf('Validator/isValid: INVALID - found NI edge in dynamic loop\n'); end
                end
                
            end
            
            % If Integral->Derivative -> NOT OK, because derivative
            % causality in loop (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for derivative edges in dynamic loops\n'); end
            for i=1:length(SCCs)
                if size(SCCs{i})==1 % Skip unit-size trivial SCCs
                    continue
                end
                SCC=SCCs{i};
                varIdx = SCC(SCC<=numVars_NoAE);
                equIdx = SCC(SCC>numVars_NoAE)-numVars_NoAE; % Rebase equation indices to 1
                E2V = types_NoAE(equIdx,varIdx);
                [row, col] = find(E2V==obj.DEF_DER);
                for i=1:length(row)
                    equId = equIds_NoAE(row(i));
                    varId = varIds_NoAE(col(i));
                    offendingEdges(end+1,:) = [equId varId];
                    if obj.debug; fprintf('Validator/isValid: INVALID - found matched derivative edge in dynamic loop\n'); end
                end
            end
            
            % Reduce SCCs
            if obj.debug; fprintf('Validator/isValid: Reducing graph\n'); end
            [graph_NoSCC, types_NoSCC, varIds_NoSCC, equIds_NoSCC, varIdMap_NoSCC, equIdMap_NoSCC] = obj.reduceSCCs(graph_NoAE, types_NoAE, varIds_NoAE, equIds_NoAE, SCCs);
            numVars_NoSCC = length(varIds_NoSCC);
            numEqs_NoSCC = length(equIds_NoSCC);            
            
            % Find all paths
            if obj.debug; fprintf('Validator/isValid: Checking for SCCs\n'); end
            adjList = createAdjList(graph_NoSCC); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            if any(find(cellfun(@(x) length(x)>1,SCCs)))
                error('This graph should not contain any loops');
            end            
            
            % If matched NI in path -> NOT OK (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for NI edges in paths\n'); end
            E2V = types_NoSCC(numVars_NoSCC+1:end,1:numVars_NoSCC);
            [row, col] = find(E2V==obj.DEF_NI);
            for i=1:length(row)
                equId = equIds_NoSCC(row(i));
                varId = varIds_NoSCC(col(i));
                offendingEdges(end+1,:) = [equId varId];
                if obj.debug; fprintf('Validator/isValid: INVALID - found matched NI edge in path\n'); end
            end
            
            % If Derivative->Integral, NOT OK (FlAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for integral edges in paths\n'); end
            E2V = types_NoSCC(numVars_NoSCC+1:end,1:numVars_NoSCC);
            [row, col] = find(E2V==obj.DEF_INT);
            for i=1:length(row)
                equId = equIds_NoSCC(row(i));
                varId = varIds_NoSCC(col(i));
                offendingEdges(end+1,:) = [equId varId];
                if obj.debug; fprintf('Validator/isValid: INVALID - found matched integral edge in path\n'); end
            end
            
            Assert that all offending edges belong to the original graph
%             if any(cellfun(@(x) find(x(1)>obj.numEqs),offendingEdges))
%                 error('The offending edge is adjacent 
            
        end
        
        function [graphReduced, typesReduced, newVarIds, newEquIds, varIdMap, equIdMap] = reduceSCCs(obj, graph, types, oldVarIds, oldEquIds, SCCs)
            % Delete trivial single-sized SCCs
            for i=length(SCCs):-1:1
                if length(SCCs{i})==1
                    SCCs(i) = [];
                end
            end
            
            numVars = length(oldVarIds);
            numEqs = length(oldEquIds);
            
            oldV2E = graph(1:numVars,numVars+1:end);
            oldE2V = graph(numVars+1:end,1:numVars);            
            oldV2E_types = types(1:numVars,numVars+1:end);
            oldE2V_types = types(numVars+1:end,1:numVars);
            
            varIdMap = oldVarIds;
            equIdMap = oldEquIds;
            SCCVarGroups = {};
            SCCEquGroups = {};
            vars2Keep = oldVarIds;
            eqs2Keep = oldEquIds;
            
            varPivot = max(oldVarIds);
            equPivot = max(oldEquIds);
            
            for i=1:length(SCCs) % Separate variable and equation IDs for each group;
                SCC = SCCs{i};
                SCCVars = SCC(SCC<=numVars);
                SCCEqs = SCC(SCC>numVars)-numVars;
                
                % Create id mappings
                varIdMap(SCCVars) = varPivot + i;
                equIdMap(SCCEqs) = equPivot + i;
                
                SCCVarGroups{i} = SCCVars;
                SCCEquGroups{i} = SCCEqs;
                
                vars2Keep = setdiff(vars2Keep,SCCVarGroups{i});
                eqs2Keep = setdiff(eqs2Keep,SCCEquGroups{i});
            end
            newVarIds = [vars2Keep (1:length(SCCs))+varPivot]; % Extend id arrays with new, reduced vertices
            newEquIds = [eqs2Keep (1:length(SCCs))+equPivot];
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
                varGroupIdx = find(cellfun(@(x) ismember(rowIdx(i),x),SCCVarGroups));
                equGroupIdx = find(cellfun(@(x) ismember(colIdx(i),x),SCCEquGroups));
                if varGroupIdx == equGroupIdx % Found an edge looping inside the same SCC
                    continue % Do not add this, because we inted to eliminate this SCC
                end
                
                newV2E(varIdxMap(rowIdx(i)),equIdxMap(colIdx(i))) = 1;
                
                % Check if this edge refers to a compacted component
                if (varIdMap(rowIdx(i))==rowIdx(i)) && (equIdMap(colIdx(i))==colIdx(i))
                    assigned_type = oldV2E_types(rowIdx(i),colIdx(i)); % The same edge from old IDs to new IDs is preserved
                else
                    assigned_type = 1;
                end
                
                newV2E_types(varIdxMap(rowIdx(i)),equIdxMap(colIdx(i))) = assigned_type;
%                 assert(ismember(oldV2E_types(rowIdx(i),colIdx(i)),[1 obj.DEF_NI]),'Algebraic SCCs should not have derivative/integral connections');
            end
            
            % Convert old E2V edges to new E2V
            [rowIdx, colIdx] = find(oldE2V);
            for i=1:length(rowIdx)
                newE2V(equIdxMap(rowIdx(i)),varIdxMap(colIdx(i))) = 1;
                
                % Check if this edge refers to a compacted component
                if (equIdMap(rowIdx(i))==rowIdx(i)) && (varIdMap(colIdx(i))==colIdx(i)) % The same edge from old IDs to new IDs is preserved
                    assigned_type = oldE2V_types(rowIdx(i),colIdx(i));
                else
                    assigned_type = 1;
                end
                
                newE2V_types(equIdxMap(rowIdx(i)),varIdxMap(colIdx(i))) = assigned_type;
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

