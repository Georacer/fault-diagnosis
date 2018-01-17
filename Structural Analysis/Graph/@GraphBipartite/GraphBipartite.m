classdef GraphBipartite < matlab.mixin.Copyable
    %GRAPHBIPARTITE Bipartite graph class definition
    %   Detailed explanation goes here
    
    properties
        equations = Equation.empty; % Array with equations contained in the graph
        variables = Variable.empty; % Array with viariables contained in the graph
        edges = Edge.empty; % Array with the edges contained in the graph
        name = '';
        coords = [];
        gi % graphInterface
    end
    
    properties (Dependent)
        numVars
        numEqs
        numEdges
    end
    
    properties (SetAccess = private)
    end
    
    properties (Hidden = true)
%         debug = false;
        debug = true;
    end
    
    
    methods
        
        %%
        function this = GraphBipartite(name,gi)
            % Constructor
            this.name = name;
            this.gi = gi;
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
        
        % Add methods
        [resp, id] = addEdge(this,id,equId,varId,edgeProps)
        [resp, id] = addEquation(this,id, alias,expressionStr, description)
        [resp, id] = addVariable(this,id,alias,description,varProps)
        resp = addEdgeToEqu(this,equIndices,edgeIndices)
        resp = addEdgeToVar(this,varIndices,edgeIndices)
        
        % delete methods
        resp = deleteEdges(this, indices)
        resp = deleteEquations(this, indices)
        resp = deleteVariables(this, indices)
        resp = removeEdgeFromEqu(this, equIndices,edgeIndices)
        resp = removeEdgeFromVar(this, varIndices,edgeIndices)
        
        % Get methods
        [ids] = getEdgesEqu(this,indices)
        [ids] = getEdgesVar(this,indices)
        [ids] = getNeighboursEqu(gh, indices)
        [ids] = getNeighboursVar(gh, indices)
        
        % Set methods
        setKnown(this,id, value)
        setMatchedVar(this,index, value, equId)
        setMatchedEqu(this,index, value, varId)
        setMatchedEdge(this,index, value)
        resp = setPropertyOREqu(this,index,property,value)
        resp = setPropertyORVar(this,index,property,value)
        resp = setPropertyOREdge(this,index,property,value)
        resp = setPropertyEqu(this,index,property,value)
        resp = setPropertyVar(this,index,property,value)
        resp = setPropertyEdges(this,index,property,value)
        resp = setEdgeWeight(gh, indices, weights)
        
        % Check methods
        resp = isKnown(this,index)
        resp = isMatchedVar(gh, index)
        resp = isMatchedEqu(gh, index)
        resp = isMatchedEdge(gh, index)
        
        resp = testPropertyEmptyVar(gh, index, property)
        resp = testPropertyEmptyEqu(gh, index, property)
        resp = testPropertyEmptyEdge(gh, index, property)
        resp = testPropertyExistsVar(gh, index, property)
        resp = testPropertyExistsEqu(gh, index, property)
        resp = testPropertyExistsEdge(gh, index, property)
        
    end
    
end

