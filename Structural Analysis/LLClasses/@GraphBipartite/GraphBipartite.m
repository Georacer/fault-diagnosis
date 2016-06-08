classdef GraphBipartite < matlab.mixin.Copyable
    %GRAPHBIPARTITE Bipartite graph class definition
    %   Detailed explanation goes here
    
    properties
        equations = Equation.empty; % Array with equations contained in the graph
        variables = Variable.empty; % Array with viariables contained in the graph
        edges = Edge.empty; % Array with the edges contained in the graph
        adjacency = Adjacency.empty; % Adjacency object
        idProvider % ID provider object
        causality = 'None'; % None, Integral, Differential, Mixed, Realistic
        name = '';
        coords = [];
        liusm = DiagnosisModel.empty;
    end
    
    properties (Dependent)
        numVars
        numEqs
        numEdges
    end
    
    properties (SetAccess = private)
        variableAliasArray = {};
        equationAliasArray = {};
        
        variableIdArray = [];
        equationIdArray = [];
        edgeIdArray = [];
        
        equationIdToIndexArray = [];
        variableIdToIndexArray = [];
        edgeIdToIndexArray = [];
        
        adjacencyUndir = []; % Undirected copy of the adjacency matrix
        adjacencyCtrl = []; % The controlability adjacency matrix
        adjacencyObsrv = []; % The observability adjacency matrix
        ph % Plot handle
    end
    
    properties (Hidden = true)
%         debug = false;
        debug = true;
    end
    
    
    methods
        
        %%
        function this = GraphBipartite(model,name,coords)
            % Constructor
            this.idProvider = IDProvider(this);

            % Read model file and store related equations and variables
            groupsNum = size(model,1); % Number of equation groups in model
            for groupIndex=1:groupsNum % For each group
                group = model{groupIndex,1};
                grEqNum = size(group,1);
                grPrefix = model{groupIndex,2};
                grEqAliases = cell(1,grEqNum); % Create unique equation aliases
                for i=1:grEqNum
                    grEqAliases{i} = sprintf('eq%d',i);
                end
                for i=1:grEqNum
                    this.parseExpression(group{i,1},grEqAliases{i},grPrefix);
                end
            end
            
            if nargin>=2
                this.name = name;
            end
            
            % Store external nodes coordinates input
            if nargin>=3
                this.coords = coords;
            end
            
        end
        
        
        %%
        function res = get.numVars(this)
            res = length(this.variables);
        end
        
        %%
        function res = get.numEqs(this)
            res = length(this.equations);
        end
        
        %%
        function res = get.numEdges(this)
            res = length(this.edges);
        end
        
        %% External methods declarations
        
        [resp, id] = addEquation(this,id, alias, prefix, expStr)
        [resp, id] = addVariable(this,id,alias,varProps,name,description)
        resp = applyMatcing(gh, M);
        [resp, id] = addEdge(this,id,equId,varId,edgeProps)
        [resp, id] = addResidual(gh, eqId);
        resp = hasCycles(this)  
        createAdjacency(this)
        list = createCostList(this, zeroWeights)
        liusm = createLiusm(gh)
        resp = deleteEdge(this, ids)
        resp = deleteEquation(this, ids)
        resp = deleteVariable(this, ids)
        [val] = evaluateSingle(this, eqId, varId)
        
        % Get methods
        alias = getAliasById(this,id)
        [tally, matching] = getAncestorEqs(this, id, tally, matching)
        dm = getDMParts(gh, X)
        [ids] = getEdgeIdArray(gh,id)
        id = getEdgeIdByProperty(this,property,value,operator)
        id = getEdgeIdByVertices(gh, equId, varId)
        E = getEdges(this,option)
        w = getEdgeWeight(gh,id);
        [ids] = getEquations(gh, ids)
        id = getEquIdByProperty(this,property,value,operator)
        [index, type] = getIndexById(this,id)
        KH = getKHComps(gh, A, equIds, varIds)
        graph = getOver(this)
        id = getParentVars(this, id)
        value = getPropertyById(this,id,property)
        [sigs, ids] = getResidualSignatures(this)
        [A, varIds, eqInd, varInd] = getSubmodel(gh, eqIds, varIds)
        id = getVariables(gh, id)
        id = getVariablesUnknown(gh, id)
        id = getVarIdByAlias(this,id)        
        id = getVarIdByProperty(this,property,value,operator)

        plotG4M(this)        
        plotDot(this)
        plotSparse(this)
        s = printEdges(gh,ids)
        plotDM(gh)
        plotMatching(this)
        setKnown(this,id, value)
        setRank(this,id,rank)
        setMatched(this,id, value)
        resp = setPropertyOR(this,id,property,value)
        resp = setProperty(this,id,property,value)
        
        resp = isVariable(this,id)
        resp = isEquation(this,id)
        resp = isEdge(this,id)
        resp = isKnown(this,id)
        resp = isMatched(gh, id)
        resp = isMatchable(gh, id)
        M = matchMurty(gh,eqIds,varIds)
        matchRanking(this)
        M = matchValid(gh, equIds, varIds);
        M = matchWeightedElimination(gh)        
        
        res = PSODecomposition(gh, X)
        res = readCostList(gh, list)
        resp = setEdgeWeight(gh, id, weight)
        sortVars(gh)
        resp = testPropertyEmpty(gh, id, property)
        resp = testPropertyExists(gh, id, property)
        parseExpression(this, exprStr, alias, prefix)
        resp = udpateEdgeIdToIndexArray(this)
        resp = updateEquationIdToIndexArray(this)
        resp = updateVariableIdToIndexArray(this)
        resp = validateMatching(gh,M)
        
    end
    
end

