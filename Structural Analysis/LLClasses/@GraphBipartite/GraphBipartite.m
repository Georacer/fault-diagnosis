classdef GraphBipartite < matlab.mixin.Copyable
    %GRAPHBIPARTITE Bipartite graph class definition
    %   Detailed explanation goes here
    
    properties
        equationArray = Equation.empty; % Array with equations contained in the graph
        variableArray = Variable.empty; % Array with viariables contained in the graph
        adjacency = Adjacency.empty; % Adjacency object
        coords = [];
    end
    
    properties (Dependent)
        numVars
        numEqs
    end
    
    properties (SetAccess = private)
        variableAliasArray = {};
        equationAliasArray = {};
        equationIdArray = [];
        variableIdArray = [];
        adjacencyUndir = []; % Undirected copy of the adjacency matrix
        adjacencyCtrl = []; % The controlability adjacency matrix
        adjacencyObsrv = []; % The observability adjacency matrix
        ph % Plot handle
    end
    
    properties (Hidden = true)
        debug = false;
%         debug = true;
        constructing = false;
    end
    
    
    methods
        
        %%
        function obj = GraphBipartite(model,coords)
            % Constructor
            
            obj.constructing = true; % Begin construction
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
                    tempEquation = Equation([],group{i,1},grEqAliases{i},grPrefix);
                    obj.equationArray(end+1) = tempEquation;
                end
            end
            
            obj.updateEquationAliasArray();
            obj.updateEquationIdArray();
            obj.updateVariableArray();
            obj.createAdjacency();
            
            % Store external nodes coordinates input
            if nargin>=2
                obj.coords = coords;
            end
            
            obj.constructing = false; % End construction
        end
        
        %%
        function set.variableArray(obj,value)
        % Set the VariableArray property and update the VariableAliaArray property
            obj.variableArray = value;
            if ~obj.constructing
                obj.updateVariableAliasArray(); % Update the variable aliases array
            end
        end
        
        %%
        function set.equationArray(obj,value)
        % Set the equationArray property and update the equationAliasArray property
            obj.equationArray = value;
            if ~obj.constructing
                obj.updateEquationAliasArray(); % Update the variable aliases array
            end
        end
        
        %%
        function res = get.numVars(obj)
            res = length(obj.variableArray);
        end
        
        %%
        function res = get.numEqs(obj)
            res = length(obj.equationArray);
        end
        
        %% External methods declarations
        E = getEdges(obj)        
        resp = hasCycles(obj)                
        updateEquationAliasArray(obj)        
        updateEquationIdArray(obj)   
        updateVariableArray(obj)
        updateVariableAliasArray(obj)     
        createAdjacency(obj)        
        plotG4M(obj)        
        plotDot(obj)
        setKnown(obj,id)
        setRank(obj,id,rank)
        setMatched(obj,id)
        matchRanking(obj)
        
    end
    
end
