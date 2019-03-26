classdef BBILPChild < matlab.mixin.Copyable
    %BBILPCHILD Child node for the BBILP matching problem
    %   Detailed explanation goes here
    
    properties
        BD = [];  % Adjacency matrix, variables indexed first, then equations
        BDMatched = [];  % Matched (directed) adjacency matrix, variables indexed first, then equations
        E2V = [];
        BD_type = [];
        cost = inf;
        matching = [];
        offendingEdges = [];  % IDs of the edges violating the matching validity
        offendingEdgesTypes = [];  % See definitions below
        % Edge types
        DEF_INT = 2;
        DEF_DER = 3;
        DEF_NI = 4;
        % Invalid edge justification
        DEF_NI_IN_DYN = 1; % Edge is non-invertible and in a dynamic loop
        DEF_DER_IN_DYN = 2; % Edge is derivative and in a dynamic loop
        DEF_NI_IN_PATH = 3; % Edge is non-invertible and in a path
        DEF_INT_IN_PATH = 4; % Edge is integral and in a path
        DEF_MULTI_MATCH = 5; % Edge is matched to multiple vertices
        DEF_RES_GEN_MATCHED = 6; % An equation marked for residual generation has been matched
        
        DEF_MAX_CYCLES = 10; % Maximum results to query when seaching for cycles where an edge participates
        
        edgesInhibited = [];
        equIdArray = [];
        varIdArray = [];
        numVars = 0;
        numEqs = 0;
        gi = GraphInterface.empty;
        
        depth = 0;
        
        debug = false;
%         debug = true;
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
                            obj.BD_type(iCount+obj.numVars,jCount) = obj.DEF_INT;
                        elseif gi.isDerivative(edgeId)
                            obj.BD(iCount+obj.numVars,jCount) = differentiationCost;
                            obj.BD_type(iCount+obj.numVars,jCount) = obj.DEF_DER;
                        elseif gi.isNonSolvable(edgeId)
                            obj.BD(iCount+obj.numVars,jCount) = nonInvertibleCost;
                            obj.BD_type(iCount+obj.numVars,jCount) = obj.DEF_NI;
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
        
        function prohibitEdges(obj, edgeIds)
            % Find new edges
            new_edges = setdiff(edgeIds, obj.edgesInhibited);
            for edgeId = new_edges
                varId = obj.gi.getVariables(edgeId);
                equId = obj.gi.getEquations(edgeId);
                varIndex = find(obj.varIdArray==varId);
                equIndex = find(obj.equIdArray==equId);
                if (~isempty(varIndex))&&(~isempty(equIndex))
                    obj.E2V(equIndex,varIndex) = inf;
                    obj.BD(obj.numVars+equIndex,varIndex) = inf;
                else
                    error('Requested inhibition of non-existing edge');
                end
            end
            obj.edgesInhibited = [obj.edgesInhibited new_edges];
        end
        
        function setCost(obj,cost)
            obj.cost = cost;
        end
        
        function setMatching(obj,matching)
            obj.matching = matching;
        end
        
        function findMatching(obj)
            
            % Obtain the cheapest unconstrained matching
            [permutations, cost] = munkres(obj.E2V);
            
            obj.BDMatched = obj.BD;
            % Disable all E2V edges
            obj.BDMatched(:,1:obj.numVars) = inf;
            
            % Apply it to the bidirectional adjacency matrix
            matching = [];
            iCounter = 1;
            for i=1:length(permutations)
                if permutations(i) % Enter only if this equation is matched
                    % Disable the V2E direction for matched edges
                    obj.BDMatched(permutations(i),i+obj.numVars)=inf;
                    % Re-enable the E2V direction for matched edges
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
            % Store the matching set
            obj.setMatching(matching);
            if length(matching)<obj.numVars % Matching is not complete on variables
                obj.setCost(inf);
            else
                obj.setCost(cost);
            end
            
        end
        
        function resp = isMatchingValid(obj)
            
            if length(obj.matching)<obj.numVars % No complete matching found
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
            offendingEdgesIDs = [];
            offendingEdgesTypes = [];
            
            % Convert offendingEdges array from N x 3 index pairs to edge IDs array
            if ~isempty(offendingEdges)
                equIndices = offendingEdges(:,1);
                varIndices = offendingEdges(:,2);
                equIds = obj.equIdArray(equIndices);
                varIds = obj.varIdArray(varIndices);
                edgeIds = zeros(1,length(equIds));
                for i=1:length(edgeIds)
                    edgeIds(i) = obj.gi.getEdgeIdByVertices(equIds(i),varIds(i));
                end
                offendingEdgesIDs = edgeIds;
                offendingEdgesTypes = offendingEdges(:,3)';
            end
               
            % Manual override, check if a matched equation has been marked for residual generator
            extra_offending_edges = obj.check_res_gens(obj.matching);
            if ~isempty(extra_offending_edges)
                offendingEdgesIDs = unique([offendingEdgesIDs extra_offending_edges]);
                offendingEdgesTypes = [offendingEdgesTypes obj.DEF_RES_GEN_MATCHED*ones(1, length(extra_offending_edges))];
            end
            
            if isempty(offendingEdgesIDs)
                resp = true;
            else
                obj.offendingEdges = offendingEdgesIDs;
                obj.offendingEdgesTypes = offendingEdgesTypes;
                resp = false;
            end
            
        end
        
        function edgeIds = check_res_gens(obj, matching)
           % Check if a matched equation had been marked as residual generator to force a matching
           edgeIds = [];
           for edge_id = matching
               equ_id = obj.gi.getEquations(edge_id);
               if obj.gi.isOfProperty(equ_id, 'isResGenerator')
                   edgeIds(end+1) = edge_id;
               end
           end
        end
        
        function edgeIds = getOffendingEdges(obj)
            edgeIds = obj.offendingEdges;
        end
        
        function branching_edges = get_branching_edges(obj)
            % Return edge IDs. Their restriction will drive the branching procedure, creating subproblems.
            % Only subproblems with invalid matchings get branched.
            % OUTPUT:
            %       branching_edges: cell array of edge ID arrays. Each edge ID array should be restricted
            %       simultaneously
            
            branching_edges = {};
            
            % Gather the offending edges
            % Edge IDs available in obj.offedingEdges
            % Invalidity justification available in obj.offendingEdgesTypes
            % Fully directed adjacency graph available at ojb.BDMatched, variables indexed first, then equations
            
            % Create the adjacency matrix
            BD = obj.BD;
            BD(BD==inf) = 0;
            BDMatched = obj.BDMatched;
            BDMatched(BDMatched==inf) = 0;
                
            % Find the branching edges according to each violation category
            for i=1:length(obj.offendingEdges)
                
                % Parse the offending edge
                offendingEdge = obj.offendingEdges(i);
                equ_id = obj.gi.getEquations(offendingEdge);
                var_id = obj.gi.getVariables(offendingEdge);
                
                equ_idx = find(obj.equIdArray==equ_id) + obj.numVars;
                var_idx = find(obj.varIdArray==var_id);
                
                % The offender edge is a candidate for restriction
                branching_edges(end+1) = {offendingEdge};
                
                % The other case is that the offending edge stays in the matching but throws other edges out of it.
                offenseType = obj.offendingEdgesTypes(i);
                switch offenseType
                        
                    case {obj.DEF_NI_IN_PATH, obj.DEF_NI_IN_DYN} % Edge is non-invertible and in a path or Edge is non-invertible and in a dynamic loop 
                        % Need to force this edge into an algebraic loop:
                        % Restrict the entry edges of algebraic loops in which this edge is part of (in the undirected
                        % graph)
                        
                        % Find the loops containing this edge
                        [ cycles, edge_list ] = findCyclesWithEdge( BD, [equ_idx, var_idx], obj.DEF_MAX_CYCLES);
                        [ results ] = parseEdgeMask( [obj.varIdArray obj.equIdArray], edge_list, cycles );
                        
                        edge_cycles = obj.vertexSeq2edgeSeq(results, obj.gi);
                        
                        % If there are such loops...
                        if ~isempty(edge_cycles)
                            for cycle_idx = 1:length(edge_cycles)
                                
                                % Make sure they are algebraic
                                loop_edge_ids = edge_cycles{cycle_idx};
                                if any(obj.gi.isIntegral(loop_edge_ids))
                                    continue;
                                end
                                
                                % Find their entry edges
                                var_ids = obj.gi.getVariables(loop_edge_ids);
                                all_edge_ids = obj.gi.getEdges(var_ids);
                                cycle_entries = setdiff(all_edge_ids, loop_edge_ids);
                                
                                % Restrict them
                                branching_edges(end+1) = {sort(cycle_entries)};
                            end
                        end                        
                        
                    case obj.DEF_DER_IN_DYN % Edge is derivative and in a dynamic loop
                        % Need to break down dynamic loop
                        % Restrict each edges of this loop matching which is an exit
                        % (exit: an edge matching a variable which is used by equations outside of the dynamic loop)
                        
                        % Get fully directed (matched) graph obj.BDMatched (already available)
                        
                        % Find the loop in which the edge participates
                        SCCs = tarjan(createAdjList(BDMatched)); % Find all Strongly Connected Components of matched graph
                        for scc_idx = 1:length(SCCs)
                            scc = SCCs{scc_idx};
                            if all(ismember([equ_idx, var_idx], scc))
                                % SCC found
                                break;
                            end
                        end
                        
                        % Find its edges
                        all_ids = [obj.varIdArray, obj.equIdArray];                        
                        vertex_ids = all_ids(sort(scc));
                        edge_list = adj2edgeL(BDMatched(scc,scc));
                        edge_mask = ones(size(edge_list,1), 1);
                        
                        [ results ] = parseEdgeMask( vertex_ids, edge_list(:,1:2), edge_mask );
                        edge_cycles = obj.vertexSeq2edgeSeq(results, obj.gi);
                        
                        % Verify that the edge is part of only one cycle
                        if length(edge_cycles)>1
                            error('Each edge of the matched graph should participate in only 1 SCC');
                        end
                        
                        % Find the loop exits
                        loop_edges = edge_cycles{1};
                        loop_matched_edge_ids = intersect(obj.matching, loop_edges);
                        for edge_id = loop_matched_edge_ids
                            var_id = obj.gi.getVariables(edge_id);
                            var_edges = obj.gi.getEdges(var_id);
                            % Check if this variable is used outside of this loop
                            if ~all(ismember(var_edges, loop_edges))
                                branching_edges(end+1) = {edge_id}; % Restrict this loop exit edge
                            end
                        end
                        
                    case obj.DEF_INT_IN_PATH % Edge is integral and in a path
                        % Need to force this edge into a dynamic loop:
                        % Restrict the entry edges of dynamic loops in which this edge is part of (in the undirected
                        % graph)
                        
                        % Find the loops containing this edge
                        [ cycles, edge_list ] = findCyclesWithEdge( BD, [equ_idx, var_idx], obj.DEF_MAX_CYCLES);
                        [ results ] = parseEdgeMask( [obj.varIdArray obj.equIdArray], edge_list, cycles );
                        
                        edge_cycles = obj.vertexSeq2edgeSeq(results, obj.gi);
                        
                        % If there are such loops...
                        if ~isempty(edge_cycles)
                            for cycle_idx = 1:length(edge_cycles)
                                
                                % Make sure they are dynamic
                                loop_edge_ids = edge_cycles{cycle_idx};
                                if ~any(obj.gi.isIntegral(loop_edge_ids))
                                    continue;
                                end
                                
                                % Find their entry edges
                                var_ids = obj.gi.getVariables(loop_edge_ids);
                                all_edge_ids = obj.gi.getEdges(var_ids);
                                cycle_entries = setdiff(all_edge_ids, loop_edge_ids);
                                
                                % Restrict them
                                branching_edges(end+1) = {sort(cycle_entries)};
                            end
                        end        
                                                
                        
                    case obj.DEF_MULTI_MATCH % Edge is matched to multiple vertices
                        error('This type of offense should not be handled within BBILP context');
                        
                    case obj.DEF_RES_GEN_MATCHED % Edge belongs to an equation marked for residual generation
                        continue;
                        
                    otherwise
                        error('Unknown offense type %d. Cannot handle', offenseType);
                end
            end
            
            % Verify each edge is staged only once for restriction
            edge_strings = cellfun(@(x)(mat2str(x)), branching_edges, 'uniformoutput', false);
            [~, unique_idx, ~] = unique(edge_strings);
            branching_edges = branching_edges(unique_idx);
            
        end
        
        function childObj = createChild(obj)
            childObj = copy(obj);
            childObj.depth = obj.depth+1;
        end
        
        function edge_cycles = vertexSeq2edgeSeq(obj, results, gi)
           % Convert a sequence of vertex IDs to a sequence of edge IDs
           % INPUTS:
           %    results: A cell vector, containing a numerical sequence of vertex IDs
           %    gi: A GraphInterface, to query edge IDs
           % OUTPUTS:
           %    edge_cycles: A cell vector, containing a numerical sequence of edge IDs
            edge_cycles = cell(1,length(results));
            for cycle_idx=1:size(results,2)
                sequence = results{cycle_idx};
                cycle_edge_ids = [];
                for edge_idx=1:(length(sequence)-1)
                    parent_id = sequence(edge_idx);
                    child_id = sequence(edge_idx+1);
                    if parent_id==child_id
%                         warning('BBILPChild: parent and child vertex ids are identical');
                        continue;
                    end
                    try
                        edge_id = gi.getEdgeIdByVertices(parent_id, child_id);
                    catch me
%                         warning('BBILPChild: Could not acquire edge from vertices');
                        continue;
                    end
                        
                    if ~isempty(edge_id)
                        cycle_edge_ids(end+1) = edge_id;
                    end
                end
                edge_cycles(cycle_idx) = {cycle_edge_ids};
            end
        end

    end
    
end

