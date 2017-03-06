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
            graphDir_NoDynamics = obj.graphDir;
            [intEdges_rows intEdges_cols] = find(graphDir_NoDynamics==obj.DEF_INT); % Find integral edges
            [derEdges_rows derEdges_cols] = find(graphDir_NoDynamics==obj.DEF_DER); % Find derivative edges
            for i=1:length(intEdges_rows) % Delete integral edges
                graphDir_NoDynamics(intEdges_rows(i),intEdges_rows(i)) = 0;
            end
            for i=1:length(derEdges_rows) % Delete derivative edges
                graphDir_NoDynamics(derEdges_rows(i),derEdges_rows(i)) = 0;
            end
            
            % Find all SCCs
            adjList = createAdjList(graphDir_NoDynamics); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            
            % If NI in SCC -> OK, nlsolver needed
            if ~isempty(SCCs) % If there are algebraic loops
                for i=1:length(SCCs) % For each one
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
            [graph_NoAE, types_NoAE, newNumVars, newNumEqs] = obj.reduceSCCs(obj.graphDir, obj.graphTypes, obj.numVars, obj.numEqs, SCCs);

            % Find all SCCs (These should be strictly dynamic)
            adjList = createAdjList(graph_NoAE); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            
            % Assert that all SCCs are dynamic
            for i=1:length(SCCs)
                SCC = SCCs{i};
                if ~find(types_NoAE(SCC,SCC)==obj.DEF_INT)
                    error('This SCC should be dynamic but no integral edge found');
                end
                
            end
            
            % If NI in SCC -> NOT OK, because they do pure back-substitution
            % (FLAG offending edges)
            if find(types_NoAE==obj.DEF_NI)
                error('Found Non-Invertible edge in a dynamic loop');
            end
            
            % If Integral->Derivative -> NOT OK, because derivative
            % causality in loop (FLAG offending edges)
            for i=1:length(SCCs)
                SCC=SCCs{i};
                tempTypes = types_NoAE(SCC,SCC);
                if find(tempTypes==obj.DEF_DER)
                    error('Found matched derivative edge in dynamic loop');
                end
            end
            
            % Reduce SCCs
            [graph_NoSCC, types_NoSCC, newNumVars, newNumEqs] = obj.reduceSCCs(graph_NoAE, types_NoAE, newNumVars, newNumEqs, SCCs);
            
            % Find all paths
            adjList = createAdjList(graph_NoSCC); % Convert to adjacency list
            SCCs = tarjan(adjList); % Find all Strongly Connected Components
            if ~isempty(SCCs)
                error('This graph should not contain any loops');
            end            
            
            % If NI in path -> NOT OK (FLAG offending edges)
            if find(types_NoSCC==obj.DEF_NI)
                error('This graph should not contain any Non-Invertible edges');
            end
            
            % If Derivative->Integral, NOT OK (FlAG offending edges)
            if find(types_NoSCC==obj.DEF_DER)
                error('This graph should not contain any Derivative edges');
            end
            
        end
        
        function [GDNAE, GTNAE, newNumVars, newNumEqs] = obj.reduceSCCs(obj, graph, types, numVars, numEqs, SCCs)
            GDNAE_E2V = graph(numVars+1:end,1:numVars); % Get the E2V part
            GDNAE_V2E = graph(1:numVars,numVars+1:end); % Get the V2E part
            GTNAE_E2V = types(numVars+1:end,1:numVars); % Get the E2V types part
            GTNAE_V2E = types(1:numVars,numVars+1:end); % Get the V2E types part
            numEls = numVars+numEqs;
            
            vertices2Del = [];
            for i=1:length(SCCs)
                SCC = SCCs{i};
                vertices2Del = unique([vertices2Del SCC]);
                externalEqs = [];
                externalVars = [];
                for j=1:length(SCC)
                    vertex = SCC(j);
                    if vertex <= numVars % This is a variable
                        relatedEqs = find(graphDir_NoAE(vertex,1:numEls));
                        externalEqs = unique([externalEqs setdiff(relatedEqs,SCC)]);
                    else % This is an equation
                        relatedVars = find(graphDir_NoAE(1:numEls,vertex));
                        externalVars = unique([externalVars setdiff(relatedVars,SCC)]);
                    end
                end
                GDNAE_E2V(end+1,end+1) = 1; % Add 2 more vertices in E2V and match them
                GDNAE_V2E(end+1,end+1) = 0; % Add 2 more vertices in V2E
                GDNAE_V2E(end,relatedEqs) = 1; % Add edges from the new var to related external equations
                GDNAE_V2E(relatedVars,end) = 1; % Add edges from related external variables to new eq
                
                GTNAE_E2V(end+1,end+1) = obj.DEF_AE; % Add 2 more vertices in E2V and match them
                GTNAE_V2E(end+1,end+1) = 0; % Add 2 more vertices in V2E
                GTNAE_V2E(end,relatedEqs) = 1; % Add edges from the new var to related external equations
                GTNAE_V2E(relatedVars,end) = 1; % Add edges from related external variables to new eq
            end % New eq-var pairs have been created for all SCCs
            eqs2Del = vertices2Del(vertices2Del>numVars);
            vars2Del = setdiff(vertices2Del,eqs2Del);
            GDNAE_E2V(eqs2Del,:) = []; % Delete all eqs belonging to an SCC
            GDNAE_E2V(:,vars2Del) = []; % Delete all vars belonging to an SCC
            GTNAE_E2V(eqs2Del,:) = []; % Delete all eqs belonging to an SCC
            GTNAE_E2V(:,vars2Del) = []; % Delete all vars belonging to an SCC
            
            % Build the new arrays
            GDNAE = [zeros(size(GDNAE_V2E,1)) GDNAE_V2E;...
                GDNAE_E2V zeros(size(GDNAE_E2V,1))];
            GTNAE = [zeros(size(GTNAE_V2E,1)) GTNAE_V2E;...
                GTNAE_E2V zeros(size(GTNAE_E2V,1))];
            
            newNumVars = size(GDNAE_V2E,1);
            newNumEqs = size(GDNAE_E2V,1);
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

