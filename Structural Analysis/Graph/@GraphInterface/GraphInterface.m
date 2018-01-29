classdef GraphInterface < handle
    %GRAPHINTERFACE Interface class for graph functionality
    %   Detailed explanation goes here
    
    properties
        graph = GraphBipartite.empty
        reg = Registry.empty
        idProvider = IDProvider.empty % ID provider object
        adjacency = Adjacency.empty
        formulaList
        name = '';
    end
    
    methods
        function this = GraphInterface()
            this.idProvider = IDProvider();
            this.reg = Registry();
        end
                
        %% Add methods
        function [ respAdded, id ] = addEdge( gi, id,equId,varId,edgeProps )
            %ADDEDGE Summary of gh function goes here
            %   Detailed explanation goes here
            
%             debug = true;
            debug = false;
            
            respAdded = false;
            
            if debug; fprintf('addEdge: starting function\n'); end
            
            l1 = length(gi.graph.edges);
            l2 = length(gi.reg.edgeIdArray);
            
            if ~(l1==l2)
                error('Inconsistent edge arrays sizes');
            end
            % Lookup the edge
            if debug; fprintf('addEdge: Looking up edge ID\n'); end
            edgeId = gi.getEdgeIdByVertices(equId, varId);
            
            if isempty(edgeId) % gh edge was not yet met
                
                if debug; fprintf('addEdge: Requesting new ID\n'); end
                if isempty(id)
                    id = gi.idProvider.giveID();
                end
                
                if debug; fprintf('addEdge: Calling graph.addEdge\n'); end
                gi.graph.addEdge(id,equId,varId,edgeProps );
                gi.reg.edgeIdArray(end+1) = id;
                gi.reg.edgeIdToIndexArray(id) = l1+1;              
                
                equIndex = gi.getIndexById(equId);
                varIndex = gi.getIndexById(varId);
                edgeIndex = gi.getIndexById(id);
                if debug; fprintf('addEdge: calling graph.addEdgeToEqu\n'); end
                gi.graph.addEdgeToEqu(equIndex,edgeIndex);
                if debug; fprintf('addEdge: calling graph.addEdgeToVar\n'); end
                gi.graph.addEdgeToVar(varIndex,edgeIndex);
%                 
%                 if ismember(id,gi.graph.equations(equIndex).edgeIdArray)
%                     warning('Attempting to add an already existing edge (%d) to an equation (%d)',id,equId);
%                 end
%                 gi.graph.equations(equIndex).edgeIdArray(end+1) = id;
%                 if ismember(id,gi.graph.variables(varIndex).edgeIdArray)
%                     warning('Attempting to add an already existing edge (%d) to a variable (%d)',id,varId);
%                 end
%                 gi.graph.variables(varIndex).edgeIdArray(end+1) = id;
                
                respAdded = true;
                if debug; fprintf('addEdge: Created new edge from (%d,%d) with ID %d\n',equId,varId,id); end
            else
                warning('I should not be here');
                gi.setPropertyOR(edgeId,'isMatched',edgeProps.isMatched);
                gi.setPropertyOR(edgeId,'isDerivative',edgeProps.isDerivative);
                gi.setPropertyOR(edgeId,'isIntegral',edgeProps.isIntegral);
                gi.setPropertyOR(edgeId,'isNonSolvable',edgeProps.isNonSolvable);
            end
        end
        function [respAdded, id] = addEquation( this, id, alias, prefix, expressionStr, description )
            %ADDEQUATION Add equation to graph
            %   Detailed explanation goes here
            
            respAdded = false;
            
%             debug = true;
            debug = false;
            
            if isempty(id)
                id = this.idProvider.giveID();
            end
            
            if nargin<5
                expressionStr = '';
            end
            
            
            if nargin<6
                description = '';
            end            
            
            l1 = length(this.graph.equations);
            l2 = length(this.reg.equAliasArray);
            l3 = length(this.reg.equIdArray);
            
            if (l1==l2) && (l2==l3)
                this.graph.addEquation(id, [prefix alias], expressionStr, description);
                if debug; fprintf('addEquation: Created new equation with name %s and ID %d\n',[prefix alias],id); end
                
                this.reg.equAliasArray{end+1} = [prefix alias];
                this.reg.equIdArray(end+1) = id;
                this.reg.equIdToIndexArray(id) = l1+1;
                respAdded = true;
            else
                error('Inconsistent equation arrays sizes');
            end
            
        end
        function [ resp, resIds ] = addResidual( gi, equIds )
            %ADDRESIDUAL Add residual variables to equations
            %   Detailed explanation goes here
            
            resp = true;
            
            resIds = zeros(size(equIds));
            
            for i=1:length(equIds)
                equId = equIds(i);
                
                alias = sprintf('res_%d',equId);
                varProps.isKnown = true;
                varProps.isMeasured = false;
                varProps.isInput = false;
                varProps.isOutput = false;
                varProps.isResidual = true;
                varProps.isMatched = true;
                [respSingle, resId] = gi.addVariable([],alias,varProps);
                
                edgeProps.isMatched = true;
                edgeProps.isDerivative = false;
                edgeProps.isIntegral = false;
                edgeProps.isNonSolvable = false;
                edgeProps.weight = 1;
                [~, edgeId] = gi.addEdge([],equId,resId,edgeProps);
                gi.setMatched(edgeId);
                
                resIds(i) = resId;
                resp = resp && respSingle;
            end
            
        end
        function [respAdded, id] = addVariable( this, id,alias,varProps,description )
            %ADDVARIABLE Summary of this function goes here
            %   Detailed explanation goes here
            
            respAdded = false;
            
            debug = false;
%             debug = true;
            
            if nargin<5
                description = '';
            end
            
            l1 = length(this.graph.variables);
            l2 = length(this.reg.varAliasArray);
            l3 = length(this.reg.varIdArray);
            
            if (l1==l2) && (l2==l3)
                
                % Lookup the variable
                varId = this.getVarIdByAlias(alias);
                
                if isempty(varId) % This variable was not yet met
                    
                    if isempty(id)
                        id = this.idProvider.giveID();
                    end
                    
                    if nargin<5
                        description = '';
                    end
                    
                    this.graph.addVariable(id,alias,description,varProps);
                    if debug; fprintf('addVariable: Created new variable with name %s and ID %d\n',alias,id); end
                    
                    this.reg.varAliasArray{end+1} = alias;
                    this.reg.varIdArray(end+1) = id;
                    this.reg.varIdToIndexArray(id) = l1+1;
                    
                    respAdded = true;
                else
                    this.setPropertyOR(varId,'isKnown',varProps.isKnown);
                    this.setPropertyOR(varId,'isMeasured',varProps.isMeasured);
                    this.setPropertyOR(varId,'isInput',varProps.isInput);
                    this.setPropertyOR(varId,'isOutput',varProps.isOutput);
                    this.setPropertyOR(varId,'isMatched',varProps.isMatched);
                    this.setPropertyOR(varId,'isMatrix',varProps.isMatrix);
                    this.setPropertyOR(varId,'isFault',varProps.isMatrix);
                    id = varId;
                end
            else
                error('Inconsistent variable arrays sizes');
            end
            
            
        end
        
        %% Delete methods
        function [ resp ] = deleteEdges( this, ids )
            %DELETEEDGE Delete edges
            %   Detailed explanation goes here
            
            resp = false;
            
            debug = false;
%             debug = true;
            
            if debug; fprintf('deleteEdges: Edges for deletion: '); fprintf('%d ',ids); fprintf('\n'); end
            if debug; fprintf('deleteEdges: out of the edgelist: '); fprintf('%d ',this.reg.edgeIdArray); fprintf('\n'); end
            if ~all(this.isEdge(ids))
                error('Requested to delete an edge while passing non-edge Id');
            end
            
            for id=ids
                if this.isMatched(id)  % If this edge was matched
                    if debug; fprintf('deleteEdges: setting edge %d matched value as false\n', id); end
                    this.setMatched(id,false);  % Unmatch the edge and all related components
                end
            end
            
            edgeIndices = this.getIndexById(ids);
            
            % Build the variable ids one-by one in case two edges refer to
            % the same variable
            varIds = zeros(1,length(edgeIndices));
            for i=1:length(varIds)
               varIds(i) = this.getVariables(ids(i)); 
            end
            
            varIndices = this.getIndexById(varIds);
            this.graph.removeEdgeFromVar(varIndices,edgeIndices);
            
            equIds = this.getEquations(ids);
            equIndices = this.getIndexById(equIds);
            this.graph.removeEdgeFromEqu(equIndices,edgeIndices);
            
            this.graph.deleteEdges(edgeIndices);
            
            this.reg.update();
            
            resp = true;
            
        end
        function [ resp ] = deleteEquations( this, ids )
            %DELETEEQUATION Delete equations from graph
            %   Detailed explanation goes here
            
%             debug=true;
            debug=false;
            
            resp = false;
            
            if ~all(this.isEquation(ids));
                error('deleteEquations: Requested to delete an equation while passing non-equation Id');
            end
            
            % Find related edges
            edgeIds = [];
            for id = ids
                equIndex = this.getIndexById(id);
                edgeIds = [edgeIds this.graph.equations(equIndex).edgeIdArray];
            end
            edgeIds = unique(edgeIds);
            if debug; fprintf('deleteEquations: Deleting from equations %d ',ids); fprintf('the edges '); fprintf(' %d ',edgeIds); fprintf('\n'); end
            
            % Find related variables
            relVarIds = [];
            for id = ids
                equIndex = this.getIndexById(id);
                relVarIds = [relVarIds this.graph.equations(equIndex).neighbourIdArray];
            end
            relVarIds = unique(relVarIds);
            if debug; fprintf('deleteEquations: Deleting from equations %d ',ids); fprintf('the variables '); fprintf(' %d ',relVarIds); fprintf('\n'); end
            
            this.deleteEdges(edgeIds);
            this.deleteVariables(relVarIds,true);
            
            % % Find exclusive variables and delete them
            % for id = relVarIds
            %     varIndex = this.getIndexById(id);
            %     edgeIds2 = this.graph.variables(varIndex).edgeIdArray;
            %     if all(ismember(edgeIds2,edgeIds))
            %         if (debug)
            %             fprintf('*** Deleting variable with id %d\n',id);
            %         end
            %         this.deleteVariable(id);
            %     end
            % end
            %
            % % Delete related edges first
            % edgeId = [];
            % for id = ids
            %     edgeId = [edgeId this.getEdgeIdByVertices(id,[])];
            % end
            % this.deleteEdge(edgeId);
            
            % Delete equations
            indices = this.getIndexById(ids);
            this.graph.deleteEquations(indices);
            
            this.reg.update();
            
            resp = true;
            
        end
        function [ resp ] = deleteVariables( this, ids, safe )
            %DELETEVARIABLE Delete variable from graph
            %   Also delete related edges
            
%             debug=true;
            debug=false;
            
            resp = false;
            
            if isempty(ids)
                error('Requested to delete variables with empty ids argument');
            end
            if ~all(this.isVariable(ids))
                error('Requested to delete a variable while passing non-variable Id');
            end
            
            if nargin<3
                safe=true;
            end
            
            % Delete only orphan variables
            if safe
                newIds = [];
                for id=ids
                    if debug; fprintf('deleteVariables: Attempting to delete variable %d with equations: ',id); fprintf('%d ',this.getEquations(id)); fprintf('\n'); end
                    if isempty(this.getEquations(id))
                        newIds = [newIds id];
                        if debug; fprintf('deleteVarables: Variable is issued for deletion\n'); end
                    end
                end
                ids = newIds;
            end
            
            % Delete related edges first
            for id = ids
                edgeIds = this.getEdgeIdByVertices([],id);
                if ~isempty(edgeIds)
                    this.deleteEdges(edgeIds);
                end
            end
            
            % Delete variables
            ind2Del = this.getIndexById(ids);
            this.graph.deleteVariables(ind2Del);
            
            if debug
                fprintf('deleteVarables: %d variables left in graph\n',this.graph.numVars);
            end
            
            this.reg.update();
            
            resp = true;
            
        end
        
        %% Get methods
        function [ equIds ] = getEquations( gh, ids )
            %GETVARIABLES get equations related to a variable or edge
            %   Detailed explanation goes here
            
            % debug = true;
            debug = false;
            
            if nargin<2 % Return all of the equations
                equIds = gh.reg.equIdArray;
                return
            end            
            
            equIds = [];
            
            indices = gh.getIndexById(ids);
            
            for i=1:length(ids)
                
                if gh.isVariable(ids(i));
                    tempVect = gh.graph.variables(indices(i)).neighbourIdArray;
                    equIds = [equIds tempVect];
                    
                elseif gh.isEdge(ids(i))
                    equIds(end+1) = gh.graph.edges(indices(i)).equId;
                    
                elseif gh.isEquation(ids(i))
                    warning('Requested getEquations from an equation');
                    equIds(end+1) = ids(i);
                    
                else
                    error('Unknown object of id %d\n',ids(i));
                end
                
            end
            
        end
        function [ varIds ] = getVariables( gh, ids )
            %GETVARIABLES get variables related to equations or edges
            %   Detailed explanation goes here
            
            % debug = true;
            debug = false;
            
            varIds = [];
            
            if nargin<2
                varIds = gh.reg.varIdArray;
                return
            end
            
            indices = gh.getIndexById(ids);
            
            for i=1:length(ids)
                
                if gh.isEquation(ids(i))
                    tempVect = gh.graph.equations(indices(i)).neighbourIdArray;
                    varIds = [varIds tempVect];
                    
                elseif gh.isEdge(ids(i))
                    varIds(end+1) = gh.graph.edges(indices(i)).varId;
                    
                elseif gh.isVariable(ids(i))
                    warning('Requested getVariables from a variable');
                    varIds(end+1) = ids(i);
                    
                else
                    error('Unknown object of id %d\n',ids(i));
                end
                
            end
            
            varIds = unique(varIds);
            
        end
        function E = getEdgeList(gh, option)
            % Returns an E(m,3) matrix, which lists all of the m edges of the graph
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
            for i=1:gh.graph.numEdges
                if debug; fprintf('Examining edge with ID: %d ',gh.graph.edges(i).id); end
                flagE2V = true;
                flagV2E = true;
                equId = gh.graph.edges(i).equId;
                varId = gh.graph.edges(i).varId;
                varIndex = gh.getIndexById(gh.graph.edges(i).varId);
                if debug; fprintf('linking equtation %d and variable %d\n',gh.graph.edges(i).equId, gh.graph.edges(i).varId); end
                if gh.graph.variables(varIndex).isKnown
                    % No operation
                end
                if gh.graph.variables(varIndex).isMeasured
                    flagE2V = false;
                    if debug; fprintf('The E->V direction is disabled, because the variable is measured\n'); end
                end
                if gh.graph.variables(varIndex).isInput
                    flagE2V = false; % From equation to variable
                    if debug; fprintf('The E->V direction is disabled, because the variable is an input\n'); end
                end
                if gh.graph.variables(varIndex).isOutput
                    % No operation
                end
                if gh.graph.edges(i).isMatched
                    flagV2E = false;
                    if debug; fprintf('The V->E direction is disabled, because the edge is matched\n'); end
                elseif gh.isMatched(varId)
                    flagE2V = false;
                    if debug; fprintf('The E->V direction is disabled, because the variable is matched\n'); end
                elseif ~gh.isMatchable(gh.graph.edges(i).id)
                    flagE2V = false; % Equation to Variable
                    if debug; fprintf('The E->V direction is disabled, because the variable cannot be matched\n'); end
                end
                if flagE2V && ~noE2V
                    E(end+1,:) = [gh.graph.edges(i).equId gh.graph.edges(i).varId gh.graph.edges(i).weight]; % with added cost of solving the edge
                end
                % Variable to Equation
                if flagV2E && ~noV2E
                    E(end+1,:) = [gh.graph.edges(i).varId gh.graph.edges(i).equId 0]; % V2E edges are free
                end
            end
        end
        function [ alias ] = getAliasById( gh, id )
            %GETALIASBYID Summary of gh function goes here
            %   Detailed explanation goes here
            
            if isempty(id)
                error('Empty ID given');
            end
            if id==0
                error('ID cannot be equal to 0');
            end
            
            index = gh.getIndexById(id);
            
            alias = cell(1,length(id));
            
            k=1;
            for ind=index
                
                if gh.isVariable(id(k))
                    alias{k} = gh.graph.variables(ind).alias;
                elseif gh.isEquation(id(k))
                    alias{k} = gh.graph.equations(ind).alias;
                elseif gh.isEdge(id(k))
                    error('Edge objects do not have an alias');
                else
                    error('Unknown object type with id %d',id(k));
                end
                
                k = k+1;
                
            end
            
        end
        function [ tally, matching ] = getAncestorEqs( gh, id, tally, matching )
            %GETPARENTEQS Find all the parent equations of a variable or equation
            %   Usable only in a directed subgraph
            
            % debug = true;
            debug = false;
            
            if nargin <3
                tally = [];
                matching = [];
            end
            
            % idArray = [];
            
            % if gh.isEquation(id)
            %     tally(end+1) = id; % Add this equation to the visited list
            %     if debug; fprintf('getAncestorEqs: Sourcing parent variables of %s\n',gh.getAliasById(id)); end
            %     parentVars = gh.getParentVars(id);
            %     for i=parentVars
            %         if debug; fprintf('getAncestorEqs: Sourcing parent equation of variable %s\n',gh.getAliasById(i)); end
            %         [newIds, tally] = gh.getAncestorEqs(i, tally);
            %         idArray = unique([idArray newIds]);
            %     end
            
            if gh.isEquation(id)
                if debug
                    aliases = gh.getAliasById(id);
                    fprintf('getAncestorEqs: Sourcing parent variables of %s\n', aliases{1}); end
                parentVars = gh.getParentVars(id);
                for i=parentVars
                    if debug
                        aliases = gh.getAliasById(i);
                        fprintf('getAncestorEqs: Sourcing parent equation of variable %s\n', aliases{1}); end
                    [tally, matching] = gh.getAncestorEqs(i, tally, matching);
                end
                
                % elseif gh.isVariable(id)
                %     if gh.isMatched(id)
                %         % Find which equation gh variable is matched to
                %         varIndex = gh.getIndexById(id);
                %         equId = gh.variables(varIndex).matchedTo;
                %         if ~any(ismember(tally,equId)) % Check if this equation has been previously visited
                %             if debug; fprintf('getAncestorEqs: Adding equation %s and sourcing its ancestors.\n',gh.getAliasById(equId)); end
                %             [newIds, tally] = gh.getAncestorEqs(equId, tally);
                %             idArray = unique([equId newIds]);
                %         end
                %     end
                
            elseif gh.isVariable(id)
                if gh.isMatched(id)
                    % Find which equation gh variable is matched to
                    varIndex = gh.getIndexById(id);
                    equId = gh.graph.variables(varIndex).matchedTo;
                    if ~any(ismember(tally,equId)) % Check if this equation has been previously visited
                        if debug
                            aliases = gh.getAliasById(equId);
                            fprintf('getAncestorEqs: Adding equation %s and sourcing its ancestors.\n',aliases{1}); end
                        tally(end+1) = equId;
                        matching(end+1) = gh.getEdgeIdByVertices(equId,id);
                        [tally, matching] = gh.getAncestorEqs(equId, tally, matching);
                    end
                end
                
            else
                error('Unknown id %d\n',id);
            end
            
        end
        function [ edgeIds ] = getEdges( gh, ids)
            %GETEDGES get edges related to an equation or variable
            %   Detailed explanation goes here
            
            % debug = true;
            debug = false;
            
            edgeIds = [];
            
            if nargin<2
                edgeIds = gh.reg.equIdArray;
                return
            end
            
            indices = gh.getIndexById(ids);
            
            for i=1:length(ids)
                
                if gh.isVariable(ids(i))
                    tempVect = gh.graph.variables(indices(i)).edgeIdArray;
                    edgeIds = [edgeIds tempVect];
                    
                elseif gh.isEquation(ids(i))
                    tempVect = gh.graph.equations(indices(i)).edgeIdArray;
                    edgeIds = [edgeIds tempVect];
                    
                elseif gh.isEdge(ids(i))
                    warning('Requested getEdges from an edge');
                    edgeIds(end+1) = ids(i);
                    
                else
                    error('Unknown object of id %d\n',ids(i));
                end
                
            end
            
        end
        function [ ids ] = getEdgeIdArray( gh, id )
            %GETEDGEIDARRAY Return edgeIdArray
            %   Detailed explanation goes here
            
            if length(id)>1
                error('This function does not support array inputs');
            end
            
            [index, type] = gh.getIndexById(id);
            if type==0
                ids = gh.graph.equations(index).edgeIdArray;
            elseif type ==1
                ids = gh.graph.variables(index).edgeIdArray;
            else
                error('This function supports only Node arguments');
            end
            
        end
        function [ id ] = getEdgeIdByProperty( gh,property,value,operator )
            %GETEDGEIDBYPROPERTY Summary of gh function goes here
            %   Detailed explanation goes here
            
            if nargin<3
                value = true;
            end
            
            if nargin<4
                operator = '==';
            end
            
            id = [];
            
            for i = 1:gh.graph.numEdges
                if gh.testPropertyExists(gh.reg.edgeIdArray(i),property)
                    switch operator
                        case '=='
                            if (gh.graph.edges(i).(property) == value)
                                id(end+1) = gh.graph.edges(i).id;
                            end
                        case '<'
                            if (gh.graph.edges(i).(property) < value)
                                id(end+1) = gh.graph.edges(i).id;
                            end
                        case '>'
                            if (gh.graph.edges(i).(property) > value)
                                id(end+1) = gh.graph.edges(i).id;
                            end
                        case '<='
                            if (gh.graph.edges(i).(property) <= value)
                                id(end+1) = gh.graph.edges(i).id;
                            end
                        case '>='
                            if (gh.graph.edges(i).(property) >= value)
                                id(end+1) = gh.graph.edges(i).id;
                            end
                        case '~='
                            if (gh.graph.edges(i).(property) ~= value)
                                id(end+1) = gh.graph.edges(i).id;
                            end
                        otherwise
                            error('Unsupported operator %s\n',operator);
                    end
                else
                    error('Unsupported property %s',property)
                    
                end
            end
            
        end
        function [ ids ] = getEdgeIdByVertices( gh, equIds, varIds )
            %GETEDGEIDBYVERTICES Find edge ids by vertices
            %   Detailed explanation goes here
            
%             debug = true;
            debug = false;
            
            id = [];
            
            if ~isempty(equIds) && ~isempty(varIds)
                
                if ~all(gh.isEquation(equIds)) && ~all(gh.isVariable(equIds))
                    error('First argument contains mixed indices');
                end
                if ~all(gh.isEquation(varIds)) && ~all(gh.isVariable(varIds))
                    error('Second argument contains mixed indices');
                end
                
                if all(gh.isEquation(varIds)) && all(gh.isVariable(equIds)) % Flip inputs
                    temp = equIds;
                    equIds = varIds;
                    varIds = temp;
                end
            
            end
            
            if isempty(equIds) % Return all edges connected to varIds
                ids = gh.getEdges(varIds);
            elseif isempty(varIds) % Return all edges connected to equIds
                ids = gh.getEdges(equIds);
            else % Find matching equId-varId pairs
                ids = zeros(1,length(equIds));
                for i=1:length(equIds) % Iterate over all equation ids
                    equEdges = gh.getEdges(equIds(i)); % Find edges connected to equId
                    varEdges = gh.getEdges(varIds(i)); % Find edges connected to varId
                    index = find(ismember(equEdges,varEdges)); % Search for common edges
                    if ~isempty(index)
                        ids(i) = equEdges(index); % Assing the result
                    else
                        if debug; fprintf('Provided equId-varId pair (%d,%d) does not have a common edge',equIds(i),varIds(i)); end
                    end
                end
                ids(ids==0) = []; % Delete empty placeholders
            end
            
        end
        function [ w ] = getEdgeWeight( gh, id )
            %GETEDGEWEIGHT Summary of this function goes here
            %   Detailed explanation goes here
            
            w = zeros(size(id));
            edgeIndices = gh.getIndexById(id);
            
            for i=1:length(id)
                if ~gh.isEdge(id(i))
                    error('Requested weight of non-edge object');
                end
                w(i) = gh.graph.edges(edgeIndices(i)).weight;
            end
            
        end
        function [ id ] = getEquIdByAlias( this, alias )
            %GETEQUIDBYALIAS Summary of this function goes here
            %   Detailed explanation goes here
            
            equIndex = find(strcmp(this.reg.equAliasArray,alias));
            id = this.reg.equIdArray(equIndex);
            
        end
        function [ id ] = getEquIdByProperty(gh,property,value,operator)
            %GETIDBYPROPERTY Return an ID array with objects with requested property
            %   gh applies and searches both equations and variables
            
            if nargin<3
                value = true;
            end
            
            if nargin<4
                operator = '==';
            end
            
            id = [];
            
            for i = 1:gh.graph.numEqs
                if gh.testPropertyExists(gh.reg.equIdArray(i),property)
                    switch operator
                        case '=='
                            if (gh.graph.equations(i).(property) == value)
                                id(end+1) = gh.graph.equations(i).id;
                            end
                        case '<'
                            if (gh.graph.equations(i).(property) < value)
                                id(end+1) = gh.graph.equations(i).id;
                            end
                        case '>'
                            if (gh.graph.equations(i).(property) > value)
                                id(end+1) = gh.graph.equations(i).id;
                            end
                        case '<='
                            if (gh.graph.equations(i).(property) <= value)
                                id(end+1) = gh.graph.equations(i).id;
                            end
                        case '>='
                            if (gh.graph.equations(i).(property) >= value)
                                id(end+1) = gh.graph.equations(i).id;
                            end
                        case '~='
                            if (gh.graph.equations(i).(property) ~= value)
                                id(end+1) = gh.graph.equations(i).id;
                            end
                        otherwise
                            error('Unsupported operator %s\n',operator);
                    end
                else
                    error('Unsupported property %s',property)
                end
            end
            
        end
        function [ expr ] = getExpressionById(gh, id)
            % getExpressionById Retun the symbolic expression
            if ~gh.isEquation(id)
                error('%d is not an equation',id);
            end
            index = gh.getIndexById(id);
            expr = gh.graph.equations(index).expression;
            
        end
        function [ index, type ] = getIndexById( gh, ids )
            %GETEQINDEXBYID Return object indices for the provided IDs
            %   Also returns the object type:
            %   0: equation
            %   1: variable
            %   2: edge
            
            index = zeros(1,length(ids));
            type = zeros(1,length(ids));
            
            for i=1:length(ids)
                
                if gh.isEquation(ids(i))
                    index(i) = gh.reg.equIdToIndexArray(ids(i));
                    type(i) = 0;
                elseif gh.isVariable(ids(i))
                    index(i) = gh.reg.varIdToIndexArray(ids(i));
                    type(i) = 1;
                elseif gh.isEdge(ids(i))
                    index(i) = gh.reg.edgeIdToIndexArray(ids(i));
                    type(i) = 2;
                else
                    error('Unknown object type with id %d',ids(i));
                end
                
            end
            
        end
        function [ ids ] = getMatchedEqus(gh, varIds)
            if nargin==1
                ids = gh.getEquIdByProperty('isMatched',true);
            elseif nargin==2
                if ~all(gh.isVariable(varIds))
                    error('Only variable Ids accepted');
                end
                ids = [];
                for id=varIds
                    varIndex = gh.getIndexById(id);
                    matchedID = gh.graph.variables(varIndex).matchedTo;
                    if isempty(matchedID)
                        error('Variable %d is not matched', id);
                    end
                    ids(end+1) = matchedID;
                end
            end
        end
        function [ ids ] = getMatchedVars(gh, equIds)
            if nargin==1
            ids = gh.getVarIdByProperty('isMatched',true);
            elseif nargin==2
                if ~all(gh.isEquation(equIds))
                    error('Only equation Ids accepted');
                end
                ids = [];
                for id=equIds
                    equIndex = gh.getIndexById(id);
                    matchedID = gh.graph.equations(equIndex).matchedTo;
                    if isempty(matchedID)
                        warning('Equation %d is not matched', id);
                    else
                        ids(end+1) = matchedID;
                    end
                end
            end
        end
        function [ ids ] = getMatchedEdges(gh)
            ids = gh.getEdgeIdByProperty('isMatched',true);
        end
        function [ varId ] = getParentVars( gh, id )
            %GETPARENTVARS Return variables directly used for calculation
            %   Detailed explanation goes here
            
            % debug = true;
            debug = false;
            
            varId = [];
            
            if gh.isVariable(id) || gh.isEdge(id)
                error('getParentVars function only applies to equations\n');
            end
            
            eqIndex = gh.getIndexById(id);
            
            edgeIds = gh.graph.equations(eqIndex).edgeIdArray;
            for id=edgeIds
                if ~gh.isMatched(id)
                    if debug; fprintf('Adding variable %s\n',gh.getAliasById(id)); end
                    varId = [varId gh.getVariables(id)];
                end
            end
            
            if debug
                fprintf('getParentVars: The parent variables of %s are %d: ',gh.getAliasById(id), length(varId));
                for i=1:length(varId)
                    fprintf('%s, ',gh.getAliasById(varId(i)));
                end
                fprintf('\n');
            end
            
        end
        function [ values ] = getPropertyById( gh, ids, property )
            %GETPROPERTYBYID Get object property value by id
            %   Detailed explanation goes here
            
            values = zeros(1,length(ids));
            
            for i=1:length(ids)
                id = ids(i);
                index = gh.getIndexById(id);
                if index==0
                    error('Unkown id %d',id);
                elseif gh.testPropertyExists(id,property)
                    if gh.isEquation(id)
                        values(i) = gh.graph.equations(index).(property);
                    elseif gh.isVariable(id)
                        values(i) = gh.graph.variables(index).(property);
                    elseif gh.isEdge(id)
                        values(i) = gh.graph.edges(index).(property);
                    else
                        error('Unknown object type with id %d',id);
                    end
                    
                end
            end
            
        end
        function [ expr ] = getStrExprById ( gh, id )
            %GETSTREXPRBYID Returns the str. expression of the input id
            if ~gh.isEquation(id)
                error('%d is not an equation',id);
            end
            index = gh.getIndexById(id);
            expr = gh.graph.equations(index).expressionStr;
        end
        function [ expr ] = getStrExprByAlias( gh, alias )
            %GETSTREXPRBYALIAS Returns the str. expression of input alias
            %   Detailed explanation goes here
            
            equIndex = find(strcmp(gh.reg.equAliasArray,alias));
            expr = gh.graph.equations(equIndex).expressionStr;
            
        end
        function [ varIds ] = getVariablesKnown( gh, id )
            %GETVARIABLESKNOWN Return the known variables of a constraint
            %   Detailed explanation goes here
            
            if nargin<2
                % Get unknown variables for the whole graph
                id = gh.reg.equIdArray;
            end
            
            varIds = gh.getVariables(id);
            
            knownVars = zeros(1,length(varIds));
            for index = 1:length(knownVars)
                if gh.isKnown(varIds(index))
                    knownVars(index) = 1;
                end
            end
            
            varIds = varIds(logical(knownVars));
            varIds = unique(varIds);
            
        end
        function [ varIds ] = getVariablesUnknown( gh, id )
            %GETVARIABLESUNKNOWN Return the uknown variables of a constraint
            %   Detailed explanation goes here
            
            if nargin<2
                % Get unknown variables for the whole graph
                id = gh.reg.equIdArray;
            end
            
            varIds = gh.getVariables(id);
            
            knownVars = zeros(1,length(varIds));
            for index = 1:length(knownVars)
                if gh.isKnown(varIds(index))
                    knownVars(index) = 1;
                end
            end
            
            varIds(logical(knownVars)) = [];            
            varIds = unique(varIds);
            
        end
        function [ id ] = getVarIdByAlias( this, alias )
            %GETVARIDBYALIAS Summary of this function goes here
            %   Detailed explanation goes here
            
            varIndex = find(strcmp(this.reg.varAliasArray,alias));
            id = this.reg.varIdArray(varIndex);
            
        end
        function [ id ] = getVarIdByProperty( gh,property,value,operator )
            %GETVARIDBYPROPERTY Summary of gh function goes here
            %   Detailed explanation goes here
            
            if nargin<3
                value = true;
            end
            
            if nargin<4
                operator = '==';
            end
            
            id = [];
            
            for i = 1:gh.graph.numVars
                if gh.testPropertyExists(gh.reg.varIdArray(i),property)
                    switch operator
                        case '=='
                            if (gh.graph.variables(i).(property) == value)
                                id(end+1) = gh.graph.variables(i).id;
                            end
                        case '<'
                            if (gh.graph.variables(i).(property) < value)
                                id(end+1) = gh.graph.variables(i).id;
                            end
                        case '>'
                            if (gh.graph.variables(i).(property) > value)
                                id(end+1) = gh.graph.variables(i).id;
                            end
                        case '<='
                            if (gh.graph.variables(i).(property) <= value)
                                id(end+1) = gh.graph.variables(i).id;
                            end
                        case '>='
                            if (gh.graph.variables(i).(property) >= value)
                                id(end+1) = gh.graph.variables(i).id;
                            end
                        case '~='
                            if (gh.graph.variables(i).(property) ~= value)
                                id(end+1) = gh.graph.variables(i).id;
                            end
                        otherwise
                            error('Unsupported operator %s\n',operator);
                    end
                else
                    error('Unsupported property %s',property)
                    
                end
            end
            
        end
        
        %% Is methods
        function resp = isEdge( gh, ids )
            %ISEDGE Summary of gh function goes here
            %   Detailed explanation goes here
            
%             debug = true;
            debug = false;
            
            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            resp = zeros(size(ids));
            
            for i=1:length(resp)
                if ids(i)<=(length(gh.reg.edgeIdToIndexArray))
                    index = gh.reg.edgeIdToIndexArray(ids(i));
                    if index==0
                        resp(i) = false;
                    else
                        resp(i) = true;
                    end
                else
                    resp(i) = false;
                end
            end
            
            
        end
        function [ resp ] = isEquation( gh, ids )
            %ISEQUATION Answer whether an object is an equation
            %   Detailed explanation goes here
            
            resp = zeros(size(ids));
            
            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            for i=1:length(resp)
                if ids(i)<=(length(gh.reg.equIdToIndexArray))
                    index = gh.reg.equIdToIndexArray(ids(i));
                    if index==0
                        resp(i) = false;
                    else
                        resp(i) = true;
                    end
                else
                    resp(i) = false;
                end
            end
            
        end
        function [ resp ] = isKnown( gh, id )
            %ISMATCHED Summary of this function goes here
            %   Detailed explanation goes here
            
            index = gh.getIndexById(id);
            
            if gh.isVariable(id)
                resp = gh.graph.isKnownVar(index);
            elseif gh.isEquation(id)
                error('isKnown does not apply to equations');
            elseif gh.isEdge(id)
                error('isKnown does not apply to equations');
            else
                error('Unkown object type with ID %d',id);
            end
            
        end
        function [ resp ] = isMatched( gh, id )
            %ISMATCHED Summary of this function goes here
            %   Detailed explanation goes here
            
            index = gh.getIndexById(id);
            
            if gh.isVariable(id)
                resp = gh.graph.isMatchedVar(index);
            elseif gh.isEquation(id)
                resp = gh.graph.isMatchedEqu(index);
            elseif gh.isEdge(id)
                resp = gh.graph.isMatchedEdge(index);
            else
                error('Unkown object type with ID %d',id);
            end
            
        end
        function [ resp ] = isVariable( gh, ids )
            %ISVARIABLE Answer whether an object is a variable
            %   Detailed explanation goes here
            
            resp = zeros(size(ids));
            
            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            for i=1:length(resp)
                if ids(i)<=(length(gh.reg.varIdToIndexArray))
                    index = gh.reg.varIdToIndexArray(ids(i));
                    if index==0
                        resp(i) = false;
                    else
                        resp(i) = true;
                    end
                else
                    resp(i) = false;
                end
            end
            
        end
        function [ resp ] = isMatchable( gh, ids )
            %ISMATCHABLE Decide if an edge can be matched
            %   This should be of minimal use and functionality since
            %   this decision belongs to the LLMatcher module
            
%             debug = true;
            debug = false;
            
            if debug; fprintf('Called isMatchable of GraphInterface for edge %d\n',id); end

            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            if ~gh.isEdge(ids)
                error('Only edges can pass this test');
            end
            
            resp = ones(size(ids));
            
            for i=1:length(resp)
                edgeIndex = gh.getIndexById(ids(i));
                
                if gh.graph.edges(edgeIndex).isNonSolvable
                    resp(i) = false;
                end
                
                varId = gh.graph.edges(edgeIndex).varId;
                varIndex = gh.getIndexById(varId);
                
                if gh.isKnown(varId);
                    % No operation
                end
                
                if gh.graph.variables(varIndex).isMeasured
                    resp(i) = false;
                end
                if gh.graph.variables(varIndex).isInput
                    resp(i) = false;
                end
                if gh.graph.variables(varIndex).isOutput
                    % No operation
                end
            end
            
        end
        function [ resp ] = isIntegral(gh, ids)
            %ISINTEGRAL Decide if an edge represents an integration
            
            resp = zeros(size(ids));
            
            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            if ~gh.isEdge(ids)
                error('Only edges can pass this test');
            end
            
            for i=1:length(resp)
                edgeIndex = gh.getIndexById(ids(i));
                resp(i) = gh.graph.edges(edgeIndex).isIntegral;            
            end               
        end
        function [ resp ] = isDerivative(gh, ids)
            %ISDERIVATIVE Decide if an edge represents a differentiation
            
            resp = zeros(size(ids));
            
            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            if ~gh.isEdge(ids)
                error('Only edges can pass this test');
            end
            
            for i=1:length(resp)
                edgeIndex = gh.getIndexById(ids(i));
                resp(i) = gh.graph.edges(edgeIndex).isDerivative;            
            end       
        end
        function [ resp ] = isNonSolvable(gh, ids)
            %ISNONSOLVABLE Decide if an edge represents a non-invertibility
            
            resp = zeros(size(ids));
            
            if isempty(ids)
                error('Requested parsing of empty ID array');
            end
            
            if ~gh.isEdge(ids)
                error('Only edges can pass this test');
            end
            
            for i=1:length(resp)
                edgeIndex = gh.getIndexById(ids(i));
                resp(i) = gh.graph.edges(edgeIndex).isNonSolvable;            
            end
        end
        function [ resp ] = isFaultable( gh, ids )
            %ISMATCHED Summary of this function goes here
            %   Detailed explanation goes here
            
            if ~gh.isEquation(ids)
                error('Only equations can pass this test');
            end
            
            index = gh.getIndexById(ids);
            
            resp = zeros(size(index));
            
            for i=1:length(resp)
                resp(i) = gh.graph.equations(index(i)).isFaultable;
            end            
        end
        
        %% Set methods
        function [ resp ] = setEdgeWeight( gh, ids, weights )
            %SETEDGEWEIGHT Summary of this function goes here
            %   Detailed explanation goes here
            
            if size(ids)~=size(weights)
                error('id and weight arrays size mismatch');
            end
            
            if ~all(gh.isEdge(ids))
                error('setEdgeWeight applies only to edges');
            end
            
            indices = gh.getIndexById(ids);
            gh.graph.setEdgeWeight(indices,weights);
            
        end
        function resp = setMatched( gh, ids,  value )
            %SETPROPERTYOR Summary of gh function goes here
            %   Detailed explanation goes here
            
%             debug=true;
            debug=false;
            
            resp = false;
            
            if nargin<3
                value = true;
            end
            
            for id = ids
                if gh.isEquation(id)
                    error('Use edges to match equations');
                elseif gh.isVariable(id)
                    error('Use edges to match variables');
                elseif gh.isEdge(id)
                    index = gh.getIndexById(id);
                    equId = gh.graph.edges(index).equId;
                    equIndex = gh.getIndexById(equId);
                    varId = gh.graph.edges(index).varId;
                    varIndex = gh.getIndexById(varId);
                    
                    gh.graph.setMatchedEdge(index,value);
                    gh.graph.setMatchedEqu(equIndex, value, varId);
                    gh.graph.setMatchedVar(varIndex, value, equId);
                    gh.graph.setKnownVar(varIndex, value); % TODO: Debatable
                    
                    if debug; fprintf('GraphInterface/setMatched: setting as matched the edge %d\n',id); end
                else
                    error('Unkown object type with id %d',id);
                end
            end
            
        end
        function resp = setKnown(gh, id, value)
            %SETKNOWN Set a variable as known
            %   Detailed explanation goes here
            
            resp = false;
            
            if nargin<3
                value = true;
            end
            
            if gh.isEquation(id)
                error('setKnown only applicable to variables, not equations');
            elseif gh.isEdge(id)
                error('setKnown only applicable to variables, not edges');
            elseif gh.isVariable(id)
                index = gh.getIndexById(id);
                gh.graph.setKnownVar(index, value);
                
            % TODO: Direct edges outwards to non-matched equations

            else
                error('Unkown object type with id %d',id);
            end
            
        end
        function resp = setProperty( gh, id, property, value )
            %SETPROPERTYOR Summary of gh function goes here
            %   Detailed explanation goes here
            
            resp = false;
            
            if nargin<4
                value = true;
            end
            
            if gh.testPropertyExists(id,property)
                
                if gh.isEquation(id)
                    index = gh.getIndexById(id);
                    gh.graph.setPropertyEqu(index,property,value);
                    resp = true;
                elseif gh.isVariable(id)
                    index = gh.getIndexById(id);
                    resp = true;
                    gh.graph.setPropertyVar(index,property,value);
                elseif gh.isEdge(id)
                    index = gh.getIndexById(id);
                    gh.graph.setPropertyEdge(index,property,value);
                    resp = true;
                else
                    error('Unkown object type with id %d',id);
                end
                
            else
                error('Unknown property %s for object with ID %d',property,id);
            end
            
        end
        function resp = setPropertyOR( gi, id, property, value )
            %SETPROPERTYOR Summary of gh function goes here
            %   Detailed explanation goes here
            
            resp = false;
            
            if nargin<4
                value = true;
            end
            
            % Logical OR for properties
            if gi.isEquation(id)
                index = gi.getIndexById(id);
                gi.graph.setPropertORyEqu(index,property,value);
            elseif gi.isVariable(id)
                index = gi.getIndexById(id);
                gi.graph.setPropertyORVar(index,property,value);
            elseif gi.isEdge(id)
                index = gi.getIndexById(id);
                gi.graph.setPropertyOREdge(index,property,value);
            else
                error('Unknown object type with id %d',id);
            end
            
            
        end

        %% Other methods
        function [ resp ] = applyMatching( gh, M )
            %APPLYMATCHING Apply a matching (set of edge IDs) to the graph as Matched
            %   Detailed explanation goes here
            
            for i=1:length(M)
                m = M(i);                
                gh.setMatched(m);
            end
            
            resp = true;
            
        end
        function [ list ] = createCostList( gh, zeroWeight )
            %CREATECOSTLIST Creat a cost list for all edges
            %   Detailed explanation goes here
            
            if nargin<2
                zeroWeight = false;
            end
            
            % Initialize list: eqname, varname, weight
            list = cell(gh.numEdges,5);
            
            for i=1:gh.numEdges
                list{i,1} = gh.graph.edges(i).equId; % TODO: replace with reg.edgeIDArray but verify that order is the same
                list{i,2} = gh.graph.edges(i).varId;
                list{i,3} = gh.getAliasById(gh.graph.edges(i).equId);
                list{i,4} = gh.getAliasById(gh.graph.edges(i).varId);
                if zeroWeight
                    list{i,5} = 1;
                else
                    list{i,5} = gh.graph.edges(i).weight;
                end
            end
            
            
        end
        function resp = hasCycles(gh)
            % Answer whether the provided graph has cycles or not. Uses the
            % matlab_networks_routines library
            n = num_loops(gh.adjacency.BD);
            if n==0
                resp = false;
            else
                resp = true;
            end
        end
        function parseExpression( this, exprStr, alias, prefix )
            %PARSEEXPRESSION Parse a structural expression
            %   Parse a structural expression and create equation, variable and edge
            %   objects in the calling graph object
            
            % debug = true;
            debug = false;
            
            % Parse structural expression
            [resp, equId] = this.addEquation([], alias, prefix, exprStr);
            has_fault = false;
            
            % legend:
            % {} - normal term
            % dot - differential term
            % int - integral term
            % trig - trigonometric term
            % ni - general non-invertible term
            % inp - input variable
            % out - output variable
            % msr - measured variable
            operators = {'dot','int','ni','inp','out','msr','fault', 'sub', 'mat', 'expr'}; % Available operators
            words = strsplit(strtrim(exprStr),' '); % Split expression to operands and variables
            linkedVariables = []; % Array with variables linked to this equation
            initProperties = true; % New variable flag for properties initialization
            for i=1:size(words,2)
                if initProperties
                    isKnown = false;
                    isMeasured = false;
                    isInput = false;
                    isOutput = false;
                    isResidual = false;
                    isMatched = false;
                    isDerivative = false;
                    isIntegral = false;
                    isNonSolvable = false;
                    isSubsystem = false;
                    isMatrix = false;
                    isExpression = false;
                    initProperties = false;
                    edgeWeight = 1;
                end
                word = words{i};
                opIndex = find(strcmp(operators, word));
                if isempty(opIndex)
                    opIndex = -1; % Found a new variable alias
                end
                
                if debug; disp(sprintf('parseExpression: opIndex=%i',opIndex)); end
                
                switch opIndex % Test if the word is an operator
                    case 1
                        isIntegral = true;
                        edgeWeight = 100;
                        this.setProperty(equId,'isDynamic');
                    case 2
                        isDerivative = true;
                        edgeWeight = 100;
                        this.setProperty(equId,'isDynamic');
                    case 3
                        isNonSolvable = true;
                    case 4
                        isInput = true;
                        isKnown = true;
                    case 5
                        isOutput = true;
                    case 6
                        isMeasured = true;
                        isKnown = true;
                    case 7
                        has_fault = true;
                        this.setProperty(equId,'isFaultable');
                        % Add a virtual fault variable
                        faultVarProps.isKnown = true;
                        faultVarProps.isMeasured = false;
                        faultVarProps.isInput = true;
                        faultVarProps.isOutput = false;
                        faultVarProps.isResidual = false;
                        faultVarProps.isMatched = false;
                        faultVarProps.isMatrix = false;
                        faultVarProps.isFault = true;
                        [resp, varId] = this.addVariable([], ['f' prefix alias], faultVarProps);
                        
                        edgeProps.isMatched = false;
                        edgeProps.isDerivative = false;
                        edgeProps.isIntegral = false;
                        edgeProps.isNonSolvable = false;
                        edgeProps.weight = 1;
                        this.addEdge([],equId,varId,edgeProps);
                    case 8
                        isSubsystem = true;
                    case 9
                        isMatrix = true;
                    case 10
                        isExpression = true;
                    otherwise % Found a variable or subsystem designation
                        
                        if isSubsystem % sub keyword met previously
                            isSubsystem = false;
                            this.setProperty(equId,'subsystem',word);
                        elseif isExpression % expr keyword met previously
                            isExpression = false;
                            if has_fault
                                word = [word '+f' prefix alias];  % Add the fault to the symbolic equation
                            end
                            this.setProperty(equId,'expression',word);
                        else % This is a variable           
                            varProps.isKnown = isKnown;
                            varProps.isMeasured = isMeasured;
                            varProps.isInput = isInput;
                            varProps.isOutput = isOutput;
                            varProps.isResidual = isResidual;
                            varProps.isMatched = isMatched;
                            varProps.isMatrix = isMatrix;
                            varProps.isFault = false;  % Faults are generated specifically above
                            [resp, varId] = this.addVariable([],word,varProps);
                            
                            edgeProps.isMatched = false;
                            edgeProps.isDerivative = isDerivative;
                            edgeProps.isIntegral = isIntegral;
                            edgeProps.isNonSolvable = isNonSolvable;
                            edgeProps.weight = edgeWeight;
                            this.addEdge([],equId,varId,edgeProps);
                            
                            initProperties = true;
                        end
                        
                end
            end
            
        end
        function [ s ] = printEdges( gh, ids )
            %PRINTEDGES Summary of this function goes here
            %   Detailed explanation goes here
            
            s = [];
            for id=ids
                equId = gh.getIndexById(gh.getEquations(id));
                varId = gh.getIndexById(gh.getVariables(id));
                s = [s sprintf('%s -> %s\n',gh.getAliasById(equId),gh.getAliasById(varId))];
            end
            
            disp(s)
            
        end
        function [ resp ] = readCostList( gh, list )
            %READCOSTLIST Summary of this function goes here
            %   Detailed explanation goes here
            
            if size(list,1)~=gh.graph.numEdges
                resp = false;
                error('List length is not equal to number of graph edges');
            elseif size(list,2)~=5
                resp = false;
                error('List is expected to have 5 columns: equId, varId, equAlias, varAlias, weight');
            else
                equIds = cell2mat(list(:,1));
                varIds = cell2mat(list(:,2));
                weights = cell2mat(list(:,5));
                edgeIds = gh.getEdgeIdByVertices(equIds,varIds);
                edgeIndices = gh.getIndexById(edgeIds);
                gh.graph.setEdgeWeight(edgeIndices,weights);
            end
            
        end
        function [ resp ] = readModel(this, model )
            %READMODEL Summary of this function goes here
            %   Detailed explanation goes here
            
            resp = false;
            
            constraints = model.constraints;
            this.graph = GraphBipartite(model.name,this);
            this.reg.setGraph(this.graph);
            this.graph.coords = model.coordinates;
            
            % Read model file and store related equations and variables
            groupsNum = size(constraints,1); % Number of equation groups in model
            for groupIndex=1:groupsNum % For each group
                group = constraints{groupIndex,1};
                grEqNum = size(group,1);
                grPrefix = constraints{groupIndex,2};
                grEqAliases = cell(1,grEqNum); % Create unique equation aliases
                for i=1:grEqNum
                    grEqAliases{i} = sprintf('eq%d',i);
                end
                for i=1:grEqNum
                    this.parseExpression(group{i,1},grEqAliases{i},grPrefix);
                end
            end
            
            resp = true;
            
            this.reg.update(); % Batch update registry
            this.name = this.graph.name;
        end
        function resp = testPropertyExists( gh, ids, property )
            %TESTPROPTERTYEMPTY Summary of this function goes here
            %   Detailed explanation goes here
            
            resp = zeros(size(ids));
            
            indices = gh.getIndexById(ids);
            
            for i=1:length(ids)
                if gh.isEquation(ids(i))
                    if gh.graph.testPropertyExistsEqu(indices(i),property);
                        resp(i) = true;
                    end
                elseif gh.isVariable(ids(i))
                    if gh.graph.testPropertyExistsVar(indices(i),property);
                        resp(i) = true;
                    end
                elseif gh.isEdge(ids(i))
                    if gh.graph.testPropertyExistsEdge(indices(i),property);
                        resp(i) = true;
                    end
                else
                    error('Unknown object with id=%d',ids(i))
                end
                
            end
        end
        function resp = testPropertyEmpty( gh, ids, property )
            %TESTPROPTERTYEMPTY Summary of this function goes here
            %   Detailed explanation goes here
            
            resp = zeros(size(ids));
            
            indices = gh.getIndexById(ids);
            
            for i=1:length(ids)
                if gh.testPropertyExists(ids(i),property)
                    if gh.isEquation(ids(i))
                        if gh.graph.testPropertyEmptyEqu(indices(i),property);
                            resp(i) = true;
                        end
                    elseif gh.isVariable(ids(i))
                        if gh.graph.testPropertyEmptyVar(indices(i),property);
                            resp(i) = true;
                        end
                    elseif gh.isEdge(ids(i))
                        if gh.graph.testPropertyEmptyEdge(indices(i),property);
                            resp(i) = true;
                        end
                    else
                        error('Unknown object with id=%d',ids(i))
                    end
                    
                else
                    error('Unsupported Property %s for id %d',property,ids(i));
                end
                
            end
        end
        function resp = createAdjacency(gi)
            gi.adjacency = Adjacency(gi);
        end
    
    end
end