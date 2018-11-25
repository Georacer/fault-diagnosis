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
        
%         debug = true;
        debug = false;
        
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
            [intEdges_rows, intEdges_cols] = find(obj.graphTypes==obj.DEF_INT); % Find integral edges
            [derEdges_rows, derEdges_cols] = find(obj.graphTypes==obj.DEF_DER); % Find derivative edges
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
            % Remove trivial SCCs of unit size
            for i=length(SCCs):-1:1
                if length(SCCs{i})==1
                    SCCs(i) = [];
                end
            end
            
            % If NI in SCC -> OK, nlsolver needed
            if obj.debug; fprintf('Validator/isValid: Checking for NIs in AEs\n'); end
            if ~isempty(SCCs) % If there are algebraic loops
                AE = graphDir_NoDynamics;
                vertices2Del = setdiff(1:size(AE,1),SCCs{i});
                AE(vertices2Del,:) = []; % Delete unrelated vertices
                AE(:,vertices2Del) = [];
                if ~isempty(find(AE==obj.DEF_NI))
                    if obj.debug; fprintf('Validator/isValid: Found a matched NI edge in an algebraic loop - NL solver required\n'); end
                end
            else
                if obj.debug; fprintf('Validator/isValid: No algebraic SCCs found\n'); end
            end
            
            % Reduce the SCCs to single E-V pairs and re-connect integrations
            if obj.debug; fprintf('Validator/isValid: Reducing AEs in original graph\n'); end
            originalVarIds = 1:obj.numVars;
            originalEquIds = 1:obj.numEqs;
            [graph_NoAE, types_NoAE, varIds_NoAE, equIds_NoAE, varIdMap_NoAE, equIdMap_NoAE] = obj.reduceSCCs(obj.graphDir, obj.graphTypes, originalVarIds, originalEquIds, SCCs);
            numVars_NoAE = length(varIds_NoAE);
            numEqs_NoAE = length(equIds_NoAE);            
            
            % Find all SCCs (These should be strictly dynamic)
            if obj.debug; fprintf('Validator/isValid: Finding SCCs\n'); end
            adjList = createAdjList(graph_NoAE); % Convert to adjacency list
            SCCs_dynamic = tarjan(adjList); % Find all Strongly Connected Components
            % Remove trivial SCCs_dynamic_dynamic of uniti size
            for i=length(SCCs_dynamic):-1:1
                if length(SCCs_dynamic{i})==1
                    SCCs_dynamic(i) = [];
                end
            end
            
            % Assert that all SCCs are dynamic
            if obj.debug; fprintf('Validator/isValid: Asserting all SCCs are dynamic\n'); end
            for i=1:length(SCCs_dynamic)
                SCC = SCCs_dynamic{i};
                if ~find(types_NoAE(SCC,SCC)==obj.DEF_INT)
                    error('This SCC should be dynamic but no integral edge found');
                end
                
            end
            
            % If NI in SCC -> NOT OK, because they do pure back-substitution
            % (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for NI edges in dynamic loops\n'); end
            for i=1:length(SCCs_dynamic)
                SCC = SCCs_dynamic{i};
                % Isolate E2V part
                varIndices = SCC(SCC<=numVars_NoAE);
                equIndices = SCC(SCC>numVars_NoAE);
                relGraph = types_NoAE.*graph_NoAE; % Keep only the directed part
                E2V = relGraph(equIndices,varIndices);
                [row, col] = find(E2V==obj.DEF_NI);
                for i=1:length(row)
                    IDs = [varIds_NoAE equIds_NoAE];
                    equId = IDs(equIndices(row(i)));
                    varId = IDs(varIndices(col(i)));
%                     equId = equIds_NoAE(row(i));
%                     varId = varIds_NoAE(col(i));
                    offendingEdges(end+1,:) = [equId varId];
                    if obj.debug; fprintf('Validator/isValid: INVALID - found NI edge in dynamic loop\n'); end
                end
                
            end
            
            % If Integral->Derivative -> NOT OK, because derivative
            % causality in loop (FLAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for derivative edges in dynamic loops\n'); end
            for i=1:length(SCCs_dynamic)
                SCC=SCCs_dynamic{i};
                varIndices = SCC(SCC<=numVars_NoAE);
                equIndices = SCC(SCC>numVars_NoAE);
                relGraph = types_NoAE.*graph_NoAE; % Keep only the directed part
                E2V = relGraph(equIndices,varIndices);
                [row, col] = find(E2V==obj.DEF_DER);
                for i=1:length(row)
                    IDs = [varIds_NoAE equIds_NoAE];
                    equId = IDs(equIndices(row(i)));
                    varId = IDs(varIndices(col(i)));
%                     equId = equIds_NoAE(row(i));
%                     varId = varIds_NoAE(col(i));
                    offendingEdges(end+1,:) = [equId varId];
                    if obj.debug; fprintf('Validator/isValid: INVALID - found matched derivative edge in dynamic loop\n'); end
                end
            end
            
            % Reduce SCCs
            if obj.debug; fprintf('Validator/isValid: Reducing graph\n'); end
            [graph_NoSCC, types_NoSCC, varIds_NoSCC, equIds_NoSCC, varIdMap_NoSCC, equIdMap_NoSCC] = obj.reduceSCCs(graph_NoAE, types_NoAE, varIds_NoAE, equIds_NoAE, SCCs_dynamic);
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
            relGraph = types_NoSCC.*graph_NoSCC; % Keep only the directed part
            E2V = relGraph(numVars_NoSCC+1:end,1:numVars_NoSCC);
            [row, col] = find(E2V==obj.DEF_NI);
            for i=1:length(row)
                equId = equIds_NoSCC(row(i));
                varId = varIds_NoSCC(col(i));
                offendingEdges(end+1,:) = [equId varId];
                if obj.debug; fprintf('Validator/isValid: INVALID - found matched NI edge in path\n'); end
            end
            
            % If Derivative->Integral, NOT OK (FlAG offending edges)
            if obj.debug; fprintf('Validator/isValid: Checking for integral edges in paths\n'); end
            relGraph = types_NoSCC.*graph_NoSCC; % Keep only the directed part
            E2V = relGraph(numVars_NoSCC+1:end,1:numVars_NoSCC);
            [row, col] = find(E2V==obj.DEF_INT);
            for i=1:length(row)
                equId = equIds_NoSCC(row(i));
                varId = varIds_NoSCC(col(i));
                offendingEdges(end+1,:) = [equId varId];
                if obj.debug; fprintf('Validator/isValid: INVALID - found matched integral edge in path\n'); end
            end
            
            % Assert that all offending edges belong to the original graph
%             if any(cellfun(@(x) find(x(1)>obj.numEqs),offendingEdges))
%                 error('The offending edge is adjacent 
            
        end
        
        function [graphReduced, typesReduced, newVarIds, newEquIds, varIdMap, equIdMap] = reduceSCCs(obj, graph, types, oldVarIds, oldEquIds, SCCs)
            
            if isempty(SCCs) % Nothing to do here
                graphReduced = graph;
                typesReduced = types;
                newVarIds = oldVarIds;
                newEquIds = oldEquIds;
                varIdMap(oldVarIds) = oldVarIds;
                equIdMap(oldEquIds) = oldEquIds;
                return
            end
            
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
            
            varIdMap = 1:max(oldVarIds);
            equIdMap = 1:max(oldEquIds);
            SCCVarGroups = {};
            SCCEquGroups = {};
            vars2Keep = oldVarIds;
            eqs2Keep = oldEquIds;
            
            varPivot = max(oldVarIds);
            equPivot = max(oldEquIds);
            
            for i=1:length(SCCs) % Separate variable and equation IDs for each group;
                SCC = SCCs{i};
                SCCVarIds = oldVarIds(SCC(SCC<=numVars));
                SCCEquIds = oldEquIds(SCC(SCC>numVars)-numVars);
                
                % Create id mappings
                varIdMap(SCCVarIds) = varPivot + i;
                equIdMap(SCCEquIds) = equPivot + i;
                
                SCCVarGroups{i} = SCCVarIds;
                SCCEquGroups{i} = SCCEquIds;
                
                vars2Keep = setdiff(vars2Keep,SCCVarGroups{i});
                eqs2Keep = setdiff(eqs2Keep,SCCEquGroups{i});
            end
            newVarIds = [vars2Keep (1:length(SCCs))+varPivot]; % Extend id arrays with new, reduced vertices
            newEquIds = [eqs2Keep (1:length(SCCs))+equPivot];
            newNumVars = length(newVarIds);
            newNumEqs = length(newEquIds);
            
            % Create old->new index mappings
            varIdxMap = zeros(size(oldVarIds));
            for i=1:length(varIdxMap)
                oldVarId = oldVarIds(i); % Find the old variable id
                newVarId = varIdMap(oldVarId); % Find the new corresponding id
                newVarIdx = find(newVarIds==newVarId); % Look it up in the new id array
                varIdxMap(i) = newVarIdx; % Store its location
            end
            equIdxMap = zeros(size(oldEquIds));
            for i=1:length(equIdxMap)
                oldEquId = oldEquIds(i); % Find the old equation id
                newEquId = equIdMap(oldEquId); % Find the new corresponding id
                newEquIdx = find(newEquIds==newEquId); % Look it up in the new id array
                equIdxMap(i) = newEquIdx; % Store its location
            end
            
            % Allocate the new reduced array
            newE2V = zeros(newNumEqs, newNumVars);
            newV2E = zeros(newNumVars, newNumEqs);
            newE2V_types = zeros(newNumEqs, newNumVars);
            newV2E_types = zeros(newNumVars, newNumEqs);
            
            % Convert old V2E edges to new V2E            
            [rowIdx, colIdx] = find(oldV2E);
            for i=1:length(rowIdx)
                varId = oldVarIds(rowIdx(i));
                equId = oldEquIds(colIdx(i));
                varGroupIdx = find(cellfun(@(x) ismember(varId,x),SCCVarGroups));
                equGroupIdx = find(cellfun(@(x) ismember(equId,x),SCCEquGroups));
                if varGroupIdx == equGroupIdx % Found an edge looping inside the same SCC
                    continue % Do not add this, because we inted to eliminate this SCC
                end
                
                newV2E(varIdxMap(rowIdx(i)),equIdxMap(colIdx(i))) = 1; % Set the corresponding variable-equation edge
                
                % Check if the edge was pre-existing or is a new one
                oldVarId = oldVarIds(rowIdx(i));
                oldEquId = oldEquIds(colIdx(i));
                newVarId = varIdMap(oldVarId);
                newEquId = equIdMap(oldEquId);
                if (newVarId == oldVarId) % This is a preexistng edge which comes from a preexisting variable (coverss v->e and v->SCC cases)
                    assigned_type = oldV2E_types(rowIdx(i),colIdx(i)); % Preserve it as it was
                else % This edge goes from one SCC to another SCC
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
                oldEquId = oldEquIds(rowIdx(i));
                oldVarId = oldVarIds(colIdx(i));
                newVarId = varIdMap(oldVarId);
                newEquId = equIdMap(oldEquId);
                if (newEquId == oldEquId) && (newVarId == oldVarId) % The same edge from old IDs to new IDs is preserved
                    assigned_type = oldE2V_types(rowIdx(i),colIdx(i));
                else % This is the matching edge inside a reduced SCC
                    assigned_type = 1;
                end
                
                newE2V_types(equIdxMap(rowIdx(i)),varIdxMap(colIdx(i))) = assigned_type;
%                 assert(ismember(oldE2V_types(rowIdx(i),colIdx(i)),[1 obj.DEF_NI]),'Algebraic SCCs should not have derivative/integral connections');
            end
            
            % Concatenate arrays to build overall directed graph
            graphReduced = [zeros(size(newV2E,1)) newV2E; newE2V zeros(size(newE2V,1))];
            typesReduced = [zeros(size(newV2E_types,1)) newV2E_types; newE2V_types zeros(size(newE2V_types,1))];
            
        end
        
    end
    
end

